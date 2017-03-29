class WaterTanksController < ApplicationController

  def new
    @farm_block = FarmBlock.find_by(id: params[:farm_block_id])
    @water_tank = WaterTank.new
  end

  def create
    @farm_block = FarmBlock.find_by(id: params[:farm_block_id])
    @water_tank = WaterTank.new(water_tank_params)
    @water_tank.farm_block_id = @farm_block.id

    if @water_tank.save
      begin
        Sensor.create_thing(@water_tank)
        Sensor.create_thing_database(@water_tank)
        Sensor.create_thing_rule(@water_tank)
      rescue Aws::DynamoDB::Errors::ResourceInUseException => error
        @errors = error
        return render :action => 'new'
      rescue Aws::DynamoDB::Errors::ValidationException => error
        @errors = error
        return render :action => 'new'
      rescue Aws::IoT::Errors::InvalidRequestException => error
        @errors = error
        return render :action => 'new'
      end
      return redirect_to water_tank_path(@water_tank)
    else
      @errors = @water_tank.errors.messages
      return render :action => 'new'
    end
  end

  def edit
    @water_tank = WaterTank.find_by(id: params[:id])
  end

  def show
    @water_tank = WaterTank.find_by(id: params[:id])
    @alerts = @water_tank.alerts

    gon.water_tank = {}

    unless Sensor.table_exists?(@water_tank.device_EUI)
      begin
        Sensor.create_thing_database(@water_tank)
      rescue Aws::DynamoDB::Errors::ValidationException => error
        puts error
        message = "There is a problem with your sensor's device EUI!"
        @error = {
          error: error,
          message: message
        }
      end
    end

    begin
      resp = Sensor.scan_dynamodb(@water_tank)
    rescue Aws::DynamoDB::Errors::ResourceNotFoundException => error
      puts error
      message = "Sensor Database Initialising!"
      @error = {
        message: message,
        error:   error
      }
      gon.water_tank[:data] = []
    rescue Aws::DynamoDB::Errors::ValidationException => error
      puts error
      message = "There is a problem with your sensor's device EUI!"
      @error = {
        error: error,
        message: message
      }
    else
      all_items = resp.items

      calculated_data = all_items.map do |entry|
        flow_data = WaterTankData.new(@water_tank, entry["payload"]["data"], entry["timestamp"])
        flow_data.convert_base64_to_decimal
        flow_data.calculate_volume(flow_data.calculated.to_i, @water_tank)
        flow_data
      end

      gon.water_tank[:data] = calculated_data
    end

    gon.water_tank[:sensor] = @water_tank

  end

  def update
    @water_tank = WaterTank.find_by(id: params[:id])

    if @water_tank.update_attributes(water_tank_params)
      redirect_to water_tank_path(@water_tank)
    else
      render :action => 'edit'
    end
  end

  def destroy
    water_tank = WaterTank.find_by(id: params[:id])
    $iot.delete_thing({
      thing_name: water_tank.device_EUI
      })
    water_tank.destroy
    redirect_to dashboard_path(current_user)
  end

  def get_tank_data
    # outputs = WaterTank.find(params[:water_tank_id]).sensor_outputs
    # dates = []
    #
    #
    # #if the user wants data over several days
    # last_sensor_date = 0
    # outputs.each do |output|
    #   utc_timestamp = convert_timestamp_to_datetime(output.sent_at)
    #   dates.push(utc_timestamp)
    # end
    #
    # render :json => {outputs: outputs,
    #                   dates: dates}
  end

  private

  def water_tank_params
    params.require(:water_tank).permit(:height, :capacity, :name, :device_EUI, :farm_block_id)
  end

end
