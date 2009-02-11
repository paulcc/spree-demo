require File.dirname(__FILE__) + '/../spec_helper.rb'

describe Order do
  before(:each) do
    @shipment = Shipment.new                                                          
    @inventory_unit = InventoryUnit.new(:state => "sold")
    @order = Order.new(:shipments => [@shipment], :inventory_units => [@inventory_unit]) #(:address => @address = mock_model(Address, :null_object => true))
  end

  # moved from order_spec (may not be correct or relevant)
  describe "ship" do
    before(:each) {@order.state = "paid"}
    it "should transition to shipped" do
      @order.ship
      @order.state.should == 'shipped'
    end
    it "should mark inventory as shipped" do
      @inventory_unit.should_receive(:ship!)
      @order.ship
    end
  end

  describe "shipping_countries" do
    it "should return an empty array if there are no shipping methods configured" do
      ShippingMethod.stub!(:all).and_return([])
      @order.shipping_countries.should == []
    end
    it "should contain only a single country even if multiple shipping methods are configured with that same country" do
      country = Country.new(:name => "foo")
      method1 = mock_model(ShippingMethod, :zone => mock_model(Zone, :country_list => [country]))
      method2 = mock_model(ShippingMethod, :zone => mock_model(Zone, :country_list => [country]))
      ShippingMethod.stub!(:all).and_return([method1, method2])
      @order.shipping_countries.should == [country]
    end
    it "should contain the unique list of countries that fall within at least one shipping method's zone" do
      country1 = Country.new(:name => "bar")
      country2 = Country.new(:name => "foo")
      method1 = mock_model(ShippingMethod, :zone => mock_model(Zone, :country_list => [country1]))
      method2 = mock_model(ShippingMethod, :zone => mock_model(Zone, :country_list => [country2]))
      ShippingMethod.stub!(:all).and_return([method1, method2])
      @order.shipping_countries.should == [country1, country2]
    end
  end
  
  describe "shipping_methods" do
    it "should return empty array if there are no shipping methods configured" do
      ShippingMethod.stub!(:all).and_return([])
      @shipment.shipping_methods.should == []
    end
    it "should check the shipping address against the shipping method's zone" do
      zone = mock_model(Zone)
      method = mock_model(ShippingMethod, :zone => zone)
      ShippingMethod.stub!(:all).and_return([method])
      zone.should_receive(:include?).with(@address)
      @shipment.shipping_methods
    end
    it "should return empty array if none of the configured shipping methods cover the shipping address" do
      method = mock_model(ShippingMethod, :zone => mock_model(Zone, :include? => false))
      ShippingMethod.stub!(:all).and_return([method])
      @shipment.shipping_methods.should == []
    end
    it "should return all shipping methiods that cover the shipping address" do
      method1 = mock_model(ShippingMethod, :zone => mock_model(Zone, :include? => true))
      method2 = mock_model(ShippingMethod, :zone => mock_model(Zone, :include? => true))
      method3 = mock_model(ShippingMethod, :zone => mock_model(Zone, :include? => false))
      ShippingMethod.stub!(:all).and_return([method1, method2, method3])
      @shipment.shipping_methods.should == [method1, method2]
    end
  end
  
  describe "state_machine in 'address' state" do
    before :each do
      @order.state = 'in_progress'
    end
    describe "when there are no shipping methods" do
      it "next! should transition to 'creditcard'" do
        @order.stub!(:shipping_methods).and_return([])
        @order.next!
        @order.state.should == "creditcard"
      end
    end
    describe "when there is more then one shipping method" do
      it "next! should transition to 'shipping_method'" do
        @order.state = "shipment"
        @order.stub!(:shipping_methods).and_return([ShippingMethod.new, ShippingMethod.new])
        @order.next!
        @order.state.should == "shipping_method"
      end
    end
  end
  
  describe "next!" do
    it "should transition from 'shipment' to 'shipping_method'" do
      @order.state = 'shipment'
      @order.next!
      @order.state.should == "shipping_method"
    end
    it "should transition from 'shipping_method' to 'creditcard'" do
      @order.state = 'shipping_method'
      @order.next!
      @order.state.should == "creditcard"
    end
  end
end