class CreateEuVatZone < ActiveRecord::Migration
  def self.up
    # create an EU VAT zone (for optional use with EU VAT)
    zone = Zone.create :name => "EU_VAT", :description => "Countries that make up the EU VAT zone."
    countries = []
    %w[AT BE BG CY CZ DK EE FI FR DE HU IE IT LV LT LU MT NL PL PT RO SK SI ES SE GB].each do |iso|
      countries << Country.find_by_iso(iso)
    end
    
    # manually create the countries (instead of using ActiveRecord method due to some apparent issues with HMP plugin)
    countries.each do |country|
      execute "INSERT INTO zone_members (parent_id, member_id, member_type, created_at, updated_at) 
               VALUES (#{zone.id}, #{country.id}, 'Country', '#{Time.now.to_s(:db)}', '#{Time.now.to_s(:db)}')"
    end
  end

  def self.down
  end
end
