class Api::V1::MaterialBatchesController < Api::V1::ApplicationController
  before_action :set_material_batch, only: [:show, :update, :destroy]

  # GET /material_batches
  def index
    @material_batches = MaterialBatch.all

    render json: @material_batches, include: [:materials, "materials.material_type", "materials.metadata"]
  end

  # GET /material_batches/1
  def show
    render json: @material_batch, include: [:materials, "materials.material_type", "materials.metadata"]
  end

  # POST /material_batches
  def create
    @material_batch = MaterialBatch.new(material_batch_create_params)

    @material_batch.materials = material_create_params.map { |param| Api::V1::Helpers::MaterialParser.new(params: param).build }

    if @material_batch.save
      render json: @material_batch, status: :created, include: [:materials, "materials.material_type", "materials.metadata"]
    else
      render json: @material_batch.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /material_batches/1
  def update

    begin
      ActiveRecord::Base.transaction do
        if material_update_params[:relationships] and material_update_params[:relationships][:materials]
          material_update_params[:relationships][:materials][:data].each { |param|
            if param[:id]
              material = Material.find(param[:id])
              material = Api::V1::Helpers::MaterialParser.new(params: param, material: material).update

              unless @material_batch.materials.include? material
                @material_batch.materials << material
              end
            else
              @material_batch.materials << Api::V1::Helpers::MaterialParser.new(params: param).build
            end

          }
        end

        if material_batch_update_params[:attributes]
          @material_batch.update!(material_batch_update_params[:attributes])
        end

        render json: @material_batch, status: :created, include: [:materials, "materials.material_type", "materials.metadata"]
      end
    rescue 
      render json: @material_batch.errors, status: :unprocessable_entity
    end

  end

  # DELETE /material_batches/1
  def destroy
    @material_batch.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_material_batch
      @material_batch = MaterialBatch.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def material_batch_create_params
      params.require(:data).require(:attributes).permit(:name)
    end

    def material_create_params
      params.require(:data).require(:relationships).require(:materials).require(:data)
    end

    def material_batch_update_params
      params.require(:data).permit(attributes: [:name])
    end

    def material_update_params
      params.require(:data).permit!
    end
end
