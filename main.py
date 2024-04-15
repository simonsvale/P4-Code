from python import MATLAB_engine

radio_object = None
 
def find_radio(): # <------------------ Ikke færdig
    global radio_object

    radio_options = {
        '1': "8000748",
        '2': "8000758",
    }

    print("[1] USRP B210 with Serial number 8000748")
    print("[2] USRP B210 with Serial number 8000758")
    radio_choice = input("Select radio: ")
    if radio_choice in radio_options:
        selected_radio = radio_options[radio_choice]
        
        with MATLAB_engine() as matlab:
            radio_object = matlab.function_find_radio(selected_radio, 42)

    else:
        print("Invalid attack choice.")




def ssb_sweep():
    print("Performing SSB Sweep...")

def ssb_jamming(gain="10", frequency="100", timing="5"):
    print(f"Performing SSB Jamming with gain={gain}, frequency={frequency}, timing={timing}...")

def sss_jamming(gain="15", frequency="200", timing="10"):
    print(f"Performing SSS Jamming with gain={gain}, frequency={frequency}, timing={timing}...")

def pdch_exploit(gain="20", frequency="300", timing="15"):
    print(f"Performing PDCH Exploit with gain={gain}, frequency={frequency}, timing={timing}...")

def choose_attack():
    global selected_attack
    global selected_attack_func
    global gain, frequency, timing

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
        selected_attack = attack_choice
        selected_attack_func = attack_options[selected_attack]
        default_gain, default_frequency, default_timing = "10", "100", "5"
        if selected_attack == '1':
            default_gain, default_frequency, default_timing = "10", "100", "5"
        elif selected_attack == '2':
            default_gain, default_frequency, default_timing = "15", "200", "10"
        elif selected_attack == '3':
            default_gain, default_frequency, default_timing = "20", "300", "15"

        gain = input(f"Enter gain value [{default_gain}]: ") or default_gain
        frequency = input(f"Enter frequency value [{default_frequency}]: ") or default_frequency
        timing = input(f"Enter timing value [{default_timing}]: ") or default_timing
    else:
        print("Invalid attack choice.")

def run_attack():
    global selected_attack_func
    global gain, frequency, timing
    if selected_attack_func:
        confirm = input(f"Confirm running attack {selected_attack} with gain={gain}, frequency={frequency}, timing={timing}? (y/n): ")
        if confirm.lower() == 'y':
            selected_attack_func(gain, frequency, timing)
            reset_selected_attack()
    else:
        print("No attack selected. Please choose an attack first.")

def reset_selected_attack():
    global selected_attack
    global selected_attack_func
    global gain, frequency, timing
    selected_attack = None
    selected_attack_func = None
    gain = "10"
    frequency = "100"
    timing = "5"

def main_menu():
    print("Welcome to the Program!")
    print("[1] Find Radio")
    print("[2] SSB Sweep")
    print("[3] Choose Attack")
    if selected_attack:
        print("[4] Run Attack")
    else:
        print("[4] Run Attack (Not Available)")

selected_attack = None
selected_attack_func = None
gain = "10"
frequency = "100"
timing = "5"

def main():
    global selected_attack
    global selected_attack_func
    global gain, frequency, timing
    options = {
        '1': find_radio,
        '2': ssb_sweep,
        '3': choose_attack,
        '4': run_attack
    }

    while True:
        main_menu()
        user_input = input("Enter the number of your choice or 'exit' to exit: ")

        if user_input.lower() == 'exit':
            print("Exiting the program.")
            break
        
        if user_input == '3':
            options[user_input]()
        elif user_input == '4':
            options[user_input]()
        elif user_input in options:
            options[user_input]()
        else:
            print("Invalid choice. Please enter a number from 1 to 4.")

if __name__ == "__main__":
    main()