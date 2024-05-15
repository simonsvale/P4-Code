import csv
from .radio_controller import RadioController
from .attack_mode import AttackMode


class CLI:
    """A Command Line Interface to scan and attack 5G networks."""

    def __init__(self) -> None:
        self.rc = RadioController()
        self._reset_attack_parameters()

    def _reset_attack_parameters(self) -> None:
        """Reset all parameters used for an attack to their default value."""
        self.selected_attack_func: function | None = None
        self.frequency: str = "1857850000"
        self.duration: str = "10"
        self.attack_mode: AttackMode = AttackMode.SMART

    def run(self) -> None:
        """Main entry to run this CLI."""

        # Available methods to run from the CLI
        available_methods: dict[str, function] = {
            "1": self._discover_radio,
            "2": self._frequency_sweep,
            "3": self._choose_attack,
            "4": self._run_attack,
        }

        while True:
            # Print all of the methods that the attacker can use
            print("[1] Discover Radio")
            print("[2] Frequency Sweep")
            print("[3] Choose Attack")
            if not self.selected_attack_func:
                print("[4] Run Attack(Unavailable)")
            else:
                print("[4] Run Attack")

            # Prompt the attacker to select a method
            selected_method: str = input(
                "Enter the number of your choice or 'exit' to exit: "
            ).lower()

            # Exit if the attacker wants to exit
            if selected_method == "exit":
                exit()

            # If the attacker selected an invalid method
            if not selected_method in available_methods:
                print("Invalid choice. Please enter 1 to 4.")
                continue

            # Otherwise run the selected method
            available_methods[selected_method]()

    def _discover_radio(self) -> None:
        """Discover and configure a selected B210 SDR."""

        radio_serial_number_options: dict[str, str] = {
            "1": "",        # The default value for auto configure
            "2": "8000748",
            "3": "8000758",
        }

        print("[1] USRP B210 with auto configured serial number")
        print("[2] USRP B210 with serial number: 8000748")
        print("[3] USRP B210 with Serial number: 8000758")

        # Prompt the attacker to select a radio/SDR
        radio_serial_number_choice: str = input("Select radio: ")

        # Check if a valid radio/SDR was selected
        if not radio_serial_number_choice in radio_serial_number_options:
            print("Invalid radio choice.")
            return

        # Configure the selected radio
        selected_sn = radio_serial_number_options[radio_serial_number_choice]
        self.rc.discover_radio(platform="B210", serial_number=selected_sn)
        print("Radio selected.")

    def _frequency_sweep(self) -> None:
        """Scan for SSBs in a selected country."""

        available_countries: list[str] = [
            "Denmark",
            "Germany",
            "Norway",
            "Sweden",
            "Finland",
            "Russia",
        ]

        # Print all of the available countries that the attacker can select
        print("Select a country for frequency sweep:")
        for i, country in enumerate(available_countries, 1):
            print(f"[{i}] {country}")

        # Prompt the attacker to select a country
        try:
            choice = int(input("Enter your choice: ")) - 1
            country = available_countries[choice]
        except (IndexError, ValueError):
            print("Invalid country name or not in list. Please try again.")
            return

        # Read frequencies from the corresponding CSV file for the selected country
        try:
            with open(f"MATLAB/data/ARFCN/{country}.csv", mode="r") as file:
                csv_reader = csv.reader(file)
                next(csv_reader)  # Skips the header row
                ARFCNs: list[int] = [int(row[0]) for row in csv_reader]
        except Exception as e:
            print(f"Failed to read the file: {e}")
            return

        # Perform frequency sweep with the read frequencies
        try:
            frequencies: list[int] = self.rc.ARFCN_to_frequency(ARFCNs)
            SSB_frequencies, timestamps = self.rc.frequency_sweep(frequencies)
            print("Frequency Sweep Results:")
            print("Frequencies:", SSB_frequencies)
            print("Timestamps:", timestamps)
        except Exception as e:
            print(f"Error during frequency sweep: {e}")
            return

    def _choose_attack(self) -> None:
        """Select an attack function."""

        available_attack_functions: dict[str, function] = {
            "1": self.rc.SSB_attack,
            "2": self._sss_jamming,  # Placeholder
            "3": self._pdch_exploit,  # Placeholder
        }

        print("Choose Attack:")
        print("[1] SSB Jamming")
        # Insert prints here for more options

        # Prompt the attacker to select a attack function
        attack_function_choice: str = input("Enter the number of the attack: ")

        # If the attacker did not chose a valid attack function
        if not attack_function_choice in available_attack_functions:
            print("Invalid attack choice.")
            return

        # Save the selected attack function so
        # that the attacker can run it later
        self.selected_attack_func = available_attack_functions[attack_function_choice]

        default_frequency: str = "1857850000"
        default_duration: str = "10"

        # Now prompt the attacker to setup the selected attack function

        if self.selected_attack_func == self.rc.SSB_attack:
            # Check if the attacker wants to use 
            # their own frequency and duration
            self.frequency = input(f"Enter frequency value [{default_frequency}]: ") or default_frequency
            self.duration = input(f"Enter duration value [{default_duration}]: ") or default_duration

            print("Choose SSB attack mode:")
            print("[1] Smart SSB Jamming")
            print("[2] Dumb SSB Jamming")
            print("[3] OFDM SSB Jamming")

            available_attack_modes: dict[str, AttackMode] = {
                "1": AttackMode.SMART,
                "2": AttackMode.DUMB,
                "3": AttackMode.OFDM
            }

            # Prompt the attacker to selected a SSB jamming mode
            attack_mode_choice: str = input(
                "Enter the number of the attack mode: "
            )

            # Check if the attacker selected a valid attack mode
            if not attack_mode_choice in available_attack_modes:
                print("Invalid attack mode choice.")
                return
        
            # Update the current attack mode to the newly chosen attack mode
            self.attack_mode = available_attack_modes[attack_mode_choice]
            return

        if self.selected_attack_func == self._sss_jamming:
            # Set default values for sss_jamming
            # This has not been implemented
            return

        if self.selected_attack_func == self._pdch_exploit:
            # Set default values for pdch_exploit
            # This ha not been implemented
            return

    def _run_attack(self) -> None:
        """Run the currently selected attack function."""

        # If no valid attack function has been selected
        if not self.selected_attack_func:
            print("No attack selected. Please choose an attack first.")
            return

        # Make sure that the attacker wants to run an attack
        print(f"Attack:         {self.selected_attack_func.__name__}")
        print(f"Attack Mode:    {self.attack_mode.name}")
        print(f"Frequency:      {self.frequency} Hz")
        print(f"Duration:       {self.duration} second(s)")
        confirmation: str = input("Confirm? (y/n): ").lower()

        if not confirmation == "y":
            print("Aborted!")
            return

        # Now run the selected attack!

        if self.selected_attack_func == self.rc.SSB_attack:
            try:
                self.rc.SSB_attack(
                    int(self.frequency),
                    int(self.duration),
                    self.attack_mode,
                )
                print("SSB attack performed successfully.")
            except Exception as e:
                print(f"Error performing SSB attack: {str(e)}")
            self._reset_attack_parameters()
            return

        if self.selected_attack_func == self._sss_jamming:
            self._sss_jamming()
            return

        if self.selected_attack_func == self._pdch_exploit:
            self._pdch_exploit()
            return

    def _sss_jamming(self):  # Delete / change
        print("[NOT IMPLEMENTED] Performing SSS Jamming with...")

    def _pdch_exploit(self):  # Delete / change
        print("[NOT IMPLEMENTED] Performing PDCH Exploit with...")
