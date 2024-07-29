{ pkgs, ...}:
{
  environment.systemPackages = with pkgs; [
    # raspberry pi
    libraspberrypi
    raspberrypi-eeprom
  ];
}
