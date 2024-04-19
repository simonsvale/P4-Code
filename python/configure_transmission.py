class Dummy:

    def find_radio(self, serial_number:str|None = None) -> object:
        """
        Takes in a radio serial number and gain-value and returns two matlab.objects, one for rx(receive) and one for tx(transmit) 
        
        :param serial_number: The serial number of the radio you wish to connect to
        """
        if not serial_number in ["8000748", "8000758", None]:
            raise Exception(f"Unknown serial number. Allowed inputs: '8000748', '8000758', or None. Current value: serial_number = {serial_number}")

        
        objects = self.eng.find_radio(serial_number)

        rx = objects[0]
        tx = objects[1]

        return rx, tx
    
    
    def configure_transmission(self, tx_object:object, center_frequency:int, gain:int = 8) -> None:
        """
        Takes in a radio transmit-object and gain-value and returns transmit-object with updated settings 
        
        :param tx_object:   The transmit-objected as created in find_radio().
        :param gain:        The antenna gain in dBm (range 0-76). Defaults to 8 dBm, which is the a low strength.
        """
        if not 0 <= gain <= 76:
            raise Exception(f"Gain-value is out of range. Allowed input is from 0 to 76, current value: gain = {gain}")        
        
        tx_updated = self.eng.configure_transmission(tx_object, center_frequency, gain)

        return tx_updated