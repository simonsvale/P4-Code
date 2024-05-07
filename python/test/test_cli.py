import unittest

from source_code.cli import CLI


class TestCLI(unittest.TestCase):

    def test_frequency_sweep(self):
        # Test for raise exception when no radio is configured
        self.assertRaises(Exception, CLI()._frequency_sweep())

"""
    def _frequency_sweep(self) -> None:
        # Prompt user to select a country
        print("Select a country for frequency sweep:")
        countries = ['Denmark','Germany','Norway','Sweden','Finland','Russia']
        for i, country in enumerate(countries, 1):
            print(f"[{i}] {country}")
        try:
            choice = int(input("Enter your choice: ")) # <---------------------------------------- user input
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
"""