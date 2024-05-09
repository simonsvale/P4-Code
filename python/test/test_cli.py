import unittest
import os
import subprocess


class TestCLI(unittest.TestCase):

    def setUp(self) -> None:
        """Setup a CLI process for testing"""

        # Move one folder up so that we are in the root project folder
        project_folder = os.path.join(os.getcwd(), os.pardir)

        # Get the absolute path of the project
        abs_project_folder = os.path.abspath(project_folder)

        self.cli_process = subprocess.Popen(
            ["python3", "main.py"],
            cwd=abs_project_folder,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            # Because Python is ran as a subprocess, piping its
            # print and input statements will raise an End Of Line
            # Error (EOF). Therefore discard its stderr.
            stderr=subprocess.DEVNULL,
        )

    def tearDown(self) -> None:
        # Close the file descriptors before termination if needed
        for fd in [self.cli_process.stdin, self.cli_process.stdout]:
            while not fd.close:
                fd.closed()

        # Terminate the cli process if it is alive
        while self.cli_process.poll() is None:
            self.cli_process.terminate()

    def cli_stdin(self, input: bytes) -> None:
        """Helper method for piping only to stdin in the cli process."""
        self.cli_process.stdin.write(input)
        self.cli_process.stdin.flush()

    def test_discover_radio(self):
        """Test for invalid radio chose."""

        # Select discover Radio option
        self.cli_stdin(b"1\n")

        # Chose an invalid radio option
        stdout, _ = self.cli_process.communicate(b"invalid\n")

        # Check if we got an invalid choice
        output = stdout.decode()
        self.assertIn("Invalid radio choice.", output)

    def test_frequency_sweep(self):
        """Test for invalid country chose."""

        # Select frequency sweep
        self.cli_stdin(b"2\n")

        # Chose an invalid country
        stdout, _ = self.cli_process.communicate(b"Edonia")

        # Check if we got an invalid choice
        output = stdout.decode()
        self.assertIn(
            "Invalid country name or not in list. Please try again.",
            output,
        )

    def test_choose_attack_with_invalid_choice(self):
        """Test for invalid attack choice."""

        # Select chose attack option
        self.cli_stdin(b"3\n")

        # Chose an invalid attack
        stdout, _ = self.cli_process.communicate(b"melee")

        # Check if we got an invalid choice
        output = stdout.decode()
        self.assertIn("Invalid attack choice.", output)

    def test_choose_attack_with_invalid_SSB_jamming(self):
        """Test for invalid SSB jamming."""

        # Select chose attack option
        self.cli_stdin(b"3\n")

        # Select SSB jamming
        self.cli_stdin(b"1\n")

        # Choose the frequency to be 1 GHz
        self.cli_stdin(b"1000000000\n")

        # Choose the duration to be 10 seconds
        self.cli_stdin(b"10\n")

        # Select an invalid SSB jamming technique
        stdout, _ = self.cli_process.communicate(b"invalid")

        # Check if we got an invalid attack mode choice
        output = stdout.decode()
        self.assertIn("Invalid attack mode choice", output)

    def test_run_attack(self):
        """Test for when no attack has been selected."""

        # Select run attack option
        stdout, _ = self.cli_process.communicate(b"4")

        # Check if we got no attack selected
        output = stdout.decode()
        self.assertIn(
            "No attack selected. Please choose an attack first.",
            output,
        )
