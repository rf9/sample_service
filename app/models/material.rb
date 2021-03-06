# See README.md for copyright details
require 'uuid'


class Material < ApplicationRecord
  belongs_to              :material_type
  has_and_belongs_to_many :material_batch
  has_many                :metadata

  validates   :name, presence: true
  validates   :uuid, uniqueness: {case_sensitive: false}, uuid: true

  after_initialize :generate_uuid, if: "uuid.nil?"

  private

  def generate_uuid
    self.uuid = UUID.new.generate
  end
end
