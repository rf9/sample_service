# See README.md for copyright details

require 'rails_helper'

RSpec.describe Material, type: :model do
  it "should make a valid material" do
    expect(build(:material)).to be_valid
  end

  it "should be invalid without a name" do
    expect(build(:material, name: nil)).to_not be_valid
  end

  it "should be invalid with a blank name" do
    expect(build(:material, name: '')).to_not be_valid
  end

  it "should have a valid UUID value" do
    expect(Material.new.uuid).to match(/^[0-9a-f]{8}-([0-9a-f]{4}-){3}[0-9a-f]{12}$/i)
  end

  it "should be invalid without a material type" do
    expect(build(:material, material_type: nil)).to_not be_valid
  end

  it "should be valid with a valid UUID parameter" do
    uuid_param = UUID.new.generate
    expect(create(:material, uuid: uuid_param)).to be_valid
    expect(Material.last.uuid).to eq(uuid_param)
  end

  it "should be invalid with a valid UUID parameter" do
    expect(build(:material, uuid: "1234")).to_not be_valid
  end

  it "should be invalid with a duplicate UUID parameter" do
    uuid_param = UUID.new.generate
    create(:material, uuid: uuid_param)
    expect(build(:material, uuid: uuid_param)).to_not be_valid
  end

end