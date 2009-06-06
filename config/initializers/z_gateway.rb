# put in test mode

Spree::Gateway::Config.set(:use_bogus => false)
ActiveMerchant::Billing::Base.gateway_mode = :test
# ActiveMerchant::Billing::Protx3dsGateway.simulate = true

# force this on, to avoid having to fix url protocols etc
Spree::Config.set(:allow_ssl_in_development_and_test => true)

# setup protx / sagepay
gw = Gateway.find_by_name("Protx3ds")


if gw.nil? 
  puts "WARNING: protx gateway configuration lost."
else
  puts " *** setting the unique gateway to Protx3ds *** "
  GatewayConfiguration.destroy_all
  gc = GatewayConfiguration.create :gateway => gw
  go = GatewayOption.find_by_gateway_id_and_name(gc.gateway.id, "login")
  gp = GatewayOptionValue.create :gateway_configuration => gc,
                                 :gateway_option => go,
                                 :value => File.read("which_vendor").chomp
end
