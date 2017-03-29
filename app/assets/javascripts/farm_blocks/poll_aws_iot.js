function poll (params) {
  var requestOptions = {
      url: '/data',
      method: 'POST',
      data: params,
      dataType: 'json'
    };

  xmlResponse = $.ajax(requestOptions);

  xmlResponse.done(function(response){

    devices = response.devices

    for (var i in devices.water_tanks){
      var waterTank = devices.water_tanks[i];
      loadGauge(waterTank, i, waterTank.type);
    }
    for (var i in devices.inflow_meters){
      var inflowMeter = devices.inflow_meters[i];
      loadGauge(inflowMeter, i, inflowMeter.type);
    }

  }).fail(function(error){
    console.log(error);
  })

  setTimeout(function(){
    poll(params)
  }, 30000);

};
