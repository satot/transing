if (!navigator.geolocation) {
  console.log("Unable to get geo location");
}

function getPosition() {
  return new Promise(function(resolve, reject){
    navigator.geolocation.getCurrentPosition(
      // callback (success)
      function(position) {
          console.log(position);
          return resolve([position.coords.latitude, position.coords.longitude]);
      },
      // callback (error)
      function(error) {
        var message = "";
        switch(error.code) {
          case 1:
            message = "PERMISSION_DENIED";
            break;
          case 2:
            message = "POSITION_UNAVAILABLE";
            break;
          case 3:
            message = "TIMEOUT";
            break;
          default:
            message = "ELSE(error code:" + error.code + ")";
            break;
        }
        return rejct(message);
      }
    );
  });
}
