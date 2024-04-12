import matlab.engine

def find_radio():
    print("Finding Radio...")

def ssb_sweep():
    print("Performing SSB Sweep...")

def ssb_jamming():
    print("Performing SSB Jamming...")

def sss_jamming():
    print("Performing SSS Jamming...")

def pdch_exploit():
    print("Performing PDCH Exploit...")

def choose_attack():
    global selected_attack
    print("Choose Attack:")
    print("[1] SSB Jamming")
    print("[2] SSS Jamming")
    print("[3] PDCH Exploit")

    attack_options = {
        '1': 'SSB Jamming',
        '2': 'SSS Jamming',
        '3': 'PDCH Exploit'
    }

    attack_choice = input("Enter the number of the attack: ")
    if attack_choice in attack_options:
        selected_attack = attack_options[attack_choice]
        print(f"Attack selected: {selected_attack}")
    else:
        print("Invalid attack choice.")

def run_attack():
    global selected_attack
    if selected_attack:
        confirm = input(f"Confirm running {selected_attack} attack? (y/n): ")
        if confirm.lower() == 'y':
            print(f"Running {selected_attack} Attack...")
            selected_attack = None
    else:
        print("No attack selected. Please choose an attack first.")

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

def main():
    global selected_attack
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
            selected_attack = None  # Reset selected attack if choosing a new one
        
        if user_input in options:
            if user_input == '4':
                options[user_input]()
            else:
                options[user_input]()
        else:
            print("Invalid choice. Please enter a number from 1 to 4.")

if __name__ == "__main__":
    main()
