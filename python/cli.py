from .RadioController import RadioController
#from attack_mode import AttackMode
import csv

class CLI:

    def __init__(self) -> None:
        self.rc = RadioController() # Radio Controller-objekt
        self.selected_attack = None
        self.selected_attack_func = None
        self.gain = "10"
        self.frequency = "100"
        self.timing = "5"
        
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
                frequencies = [int(row[0]) for row in csv_reader]
                print(frequencies)
        except Exception as e:
            print(f"Failed to read the file: {str(e)}")
            return

        # Perform frequency sweep with the read frequencies
        try:
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
            '1': ssb_jamming,
            '2': sss_jamming,
            '3': pdch_exploit
        }

        attack_choice = input("Enter the number of the attack: ")
        if attack_choice in attack_options:
            self.selected_attack = attack_choice
            self.selected_attack_func = attack_options[self.selected_attack]
            default_gain, default_frequency, default_timing = "10", "100", "5"
            if self.selected_attack == '1':
                default_gain, default_frequency, default_timing = "10", "100", "5"
            elif self.selected_attack == '2':
                default_gain, default_frequency, default_timing = "15", "200", "10"
            elif self.selected_attack == '3':
                default_gain, default_frequency, default_timing = "20", "300", "15"

            self.gain = input(f"Enter gain value [{default_gain}]: ") or default_gain
            self.frequency = input(f"Enter frequency value [{default_frequency}]: ") or default_frequency
            self.timing = input(f"Enter timing value [{default_timing}]: ") or default_timing
        else:
            print("Invalid attack choice.")

        
    def _run_attack(self) -> None:
        if self.selected_attack_func:
            confirm = input(f"Confirm running attack {self.selected_attack} with gain={self.gain}, frequency={self.frequency}, timing={self.timing}? (y/n): ")
            if confirm.lower() == 'y':
                self.selected_attack_func(self.gain, self.frequency, self.timing)
                self.reset_selected_attack()
        else:
            print("No attack selected. Please choose an attack first.")

    def reset_selected_attack(self) -> None:
        self.selected_attack = None
        self.selected_attack_func = None
        self.gain = "10"
        self.frequency = "100"
        self.timing = "5"  


def ssb_jamming(gain="10", frequency="100", timing="5"):
    print(f"Performing SSB Jamming with gain={gain}, frequency={frequency}, timing={timing}...")

def sss_jamming(gain="15", frequency="200", timing="10"):
    print(f"Performing SSS Jamming with gain={gain}, frequency={frequency}, timing={timing}...")

def pdch_exploit(gain="20", frequency="300", timing="15"):
    print(f"Performing PDCH Exploit with gain={gain}, frequency={frequency}, timing={timing}...")

if __name__ == "__main__":
    CLI().run()