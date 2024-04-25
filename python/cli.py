from .radio_controller import RadioController
from .attack_mode import AttackMode
import csv

class CLI:

    def __init__(self) -> None:
        self.rc = RadioController() # Radio Controller-objekt
        self.selected_attack = None
        self.selected_attack_func = None
        self.frequency = "100"
        self.duration = "10"
        self.attack_mode = AttackMode.SMART
        
        # self.matlab_engine
        self.radio_object = None
        
        
        # self.rc.discover_radio(serial_number:str)-> (rx:object, tx:object)
        # self.rc.frequency_sweep(frequencies: list) -> (frequencies:list_of_ints, timestamps: list_of_datetime)
        # self.rc.SSB_attack(attackMode:enum, frequency:int) -> None
        
        # self.rc.PRACH_jam() fremtid


    def run(self) -> None:
        options = {
            '1': self._discover_radio,
            '2': self._frequency_sweep,
            '3': self._choose_attack,
            '4': self._run_attack
        }

        while True:
            print("Welcome to the Program!")
            print("[1] Discover Radio")
            print("[2] Frequency Sweep")
            print("[3] Choose Attack")
            print("[4] Run Attack(Unavailable)") if not self.selected_attack else print("[4] Run Attack")

            user_input = input("Enter the number of your choice or 'exit' to exit: ")

            if user_input.lower() == 'exit': exit(0)
            
            if user_input in options:
                options[user_input]()
            else:
                print("Invalid choice. Please enter a number from 1 to 4.")

            if user_input == 1:
                pass

    def _discover_radio(self) -> None:
        radio_options = {
            '1': "",
            '2': "8000748",
            '3': "8000758",
        }
        print("[1] Auto")
        print("[2] USRP B210 with Serial number 8000748")
        print("[3] USRP B210 with Serial number 8000758")
        radio_choice = input("Select radio: ")
        if radio_choice in radio_options:
            selected_radio = radio_options[radio_choice]
            self.radio_object = self.rc.discover_radio(platform='B210', serial_number=selected_radio)
            print(f"Radio {selected_radio} selected.")
        else:
            print("Invalid radio choice.")

    def _frequency_sweep(self) -> None:
        # Prompt user to select a country
        print("Select a country for frequency sweep:")
        countries = ['Denmark','Germany','Norway','Sweden','Finland','Russia']
        for i, country in enumerate(countries, 1):
            print(f"[{i}] {country}")
        try:
            choice = int(input("Enter your choice: "))
            country = countries[choice - 1]
        except (IndexError, ValueError):
            print("Invalid country name or not in list. Please try again.")
            return

        # Read frequencies from the corresponding CSV file
        try:
            with open(f'MATLAB/data/ARFCN/{country}.csv', mode='r') as file:
                csv_reader = csv.reader(file)
                next(csv_reader)  # Skips the header row
                AFRCN = [int(row[0]) for row in csv_reader]
        except Exception as e:
            print(f"Failed to read the file: {str(e)}")
            return

        # Perform frequency sweep with the read frequencies
        try:
            frequencies = self.rc.ARFCN_to_frequency(AFRCN)
            SSB_frequencies, timestamps = self.rc.frequency_sweep(frequencies)
            print("Frequency Sweep Results:")
            print("Frequencies:", SSB_frequencies)
            print("Timestamps:", timestamps)
        except Exception as e:
            print(f"Error during frequency sweep: {str(e)}")
        

    def _choose_attack(self) -> None:
        print("Choose Attack:")
        print("[1] SSB Jamming")
        print("[2] SSS Jamming")
        print("[3] PDCH Exploit")

        attack_options = {
            '1': self.ssb_jamming,
            '2': self.sss_jamming,
            '3': self.pdch_exploit
        }

        attack_choice = input("Enter the number of the attack: ")
        if attack_choice in attack_options:
            self.selected_attack = attack_choice
            self.selected_attack_func = attack_options[self.selected_attack]
            default_frequency, default_duration = "1857850000", "10"  # Default values for frequency and duration
            if self.selected_attack == '1':
                self.frequency = input(f"Enter frequency value [{default_frequency}]: ") or default_frequency
                self.duration = input(f"Enter duration value [{default_duration}]: ") or default_duration
                # Prompt for SSB attack mode
                print("Choose SSB attack mode:")
                print("[1] Smart SSB Jamming")
                print("[2] Dumb SSB Jamming")
                attack_mode_choice = input("Enter the number of the attack mode: ")
                if attack_mode_choice == '1':
                    self.attack_mode = AttackMode.SMART
                elif attack_mode_choice == '2':
                    self.attack_mode = AttackMode.DUMB
                else:
                    print("Invalid attack mode choice.")
                    return
            elif self.selected_attack == '2':
                # Set default values for sss_jamming
                None
            elif self.selected_attack == '3':
                # Set default values for pdch_exploit
                None
        else:
            print("Invalid attack choice.")

        
    def _run_attack(self) -> None:
        if self.selected_attack_func:
            confirm = input(f"Confirm running attack {self.selected_attack} with frequency={self.frequency}, duration={self.duration} and attak mode={self.attack_mode}? (y/n): ")
            if confirm.lower() == 'y':
                try:
                    if self.selected_attack == '1':
                        # Call the SSB_attack method from RadioController
                        try:
                            self.rc.SSB_attack(int(self.frequency), int(self.duration), self.attack_mode)
                            print("SSB attack performed successfully.")
                        except Exception as e:
                            print(f"Error performing SSB attack: {str(e)}")
                    elif self.selected_attack == '2':
                        print("Not implemented")
                        return
                    elif self.selected_attack == '3':
                        print("Not implemented")
                        return
                    else:
                        print("Invalid attack choice.")
                except Exception as e:
                    print(f"Error running attack: {str(e)}")
                self.reset_selected_attack()
        else:
            print("No attack selected. Please choose an attack first.")

    def reset_selected_attack(self) -> None:
        self.selected_attack = None
        self.selected_attack_func = None
        self.frequency = "1857850000"
        self.duration = "10"
        self.attack_mode = AttackMode.SMART


    def ssb_jamming(self) -> None:
        print("Choose SSB attack mode:")
        print("[1] Smart SSB Jamming")
        print("[2] Dumb SSB Jamming")

        attack_mode_choice = input("Enter the number of the attack mode: ")
        if attack_mode_choice == '1':
            attack_mode = AttackMode.SMART
        elif attack_mode_choice == '2':
            attack_mode = AttackMode.DUMB
        else:
            print("Invalid attack mode choice.")
            return

    def sss_jamming(self):
        print(f"Performing SSS Jamming with...")

    def pdch_exploit(self):
        print(f"Performing PDCH Exploit with...")

if __name__ == "__main__":
    CLI().run()