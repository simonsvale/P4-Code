import unittest
from source_code.radio_controller import RadioController


class TestRadioController(unittest.TestCase):

    def test_ARFCN_to_frequency(self):
        ARFCN: list[int] = [
            155050,
            371570,
            423170,
            628032,
            628704,
            630048,
            636768,
            647328,
        ]
        expected_frequencies: list[int] = [
            775250000,
            1857850000,
            2115850000,
            3420480000,
            3430560000,
            3450720000,
            3551520000,
            3709920000,
        ]

        actual_frequencies = RadioController.ARFCN_to_frequency(ARFCN)
        self.assertListEqual(actual_frequencies, expected_frequencies)

    def test_GSCN_to_frequency(self):
        GSCN: list[int] = [5279, 4829, 4517, 2177, 2183, 6554, 2318, 1828]
        expected_frequencies: list[int] = [
            2112050000,
            1932050000,
            1807250000,
            871250000,
            873650000,
            2622050000,
            927650000,
            731050000,
        ]

        actual_frequencies = RadioController.GSCN_to_frequency(GSCN)
        self.assertEqual(actual_frequencies, expected_frequencies)
