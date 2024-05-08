import unittest
import os
import subprocess
from source_code.cli import CLI


class TestCLI(unittest.TestCase):

    def setUp(self) -> None:
        # Setup a CLI process for testing

        # Change path to project dir to run the CLI process from main.py
        project_dir: str = os.path.abspath(os.path.join(os.getcwd(), os.pardir))

        cmd = ["python3", "main.py"]
        self.cli_process = subprocess.Popen(
            cmd,
            cwd=project_dir,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )

    def tearDown(self) -> None:
        # Close the file descriptors before terminate if needed
        while not self.cli_process.stdin.closed:
            self.cli_process.stdin.close()

        while not self.cli_process.stdout.closed:
            self.cli_process.stdout.close()

        while not self.cli_process.stderr.closed:
            self.cli_process.stderr.close()

        # Terminate the cli process if it is alive
        while self.cli_process.poll() is None:
            self.cli_process.terminate()

    def test_discover_radio(self):
        """Test for invalid radio chose."""

        # Select discover Radio option
        self.cli_process.stdin.write(b"1\n")
        self.cli_process.stdin.flush()

        # Chose an invalid radio option
        stdout, stderr = self.cli_process.communicate(b"invalid\n")

        # Check if we got an invalid choice
        output = stdout.decode()
        self.assertIn("Invalid radio choice.", output)

    def test_frequency_sweep(self):
        self.skipTest(reason="No yet implemented unit test")

    def test_choose_attack(self):
        self.skipTest(reason="No yet implemented unit test")

    def test_run_attack(self):
        self.skipTest(reason="No yet implemented unit test")

    def test_reset_selected_attack(self):
        self.skipTest(reason="No yet implemented unit test")

    def test_sss_jamming(self):
        self.skipTest(reason="No yet implemented unit test")

    def test_pdch_exploit(self):
        self.skipTest(reason="No yet implemented unit test")


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