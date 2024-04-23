#!/bin/bash
file=database.txt
i=0

# Define country codes as key-value pairs
declare -A country_codes=(
    ["United States"]="+1"
    ["United Kingdom"]="+44"
    ["Canada"]="+1"
    ["Australia"]="+61"
    ["India"]="+91"
    ["China"]="+86"
    ["Japan"]="+81"
    ["Germany"]="+49"
    ["France"]="+33"
    ["Brazil"]="+55"
)

if ! [ -f "$file" ]; then #file not exists
    touch database.txt
fi 

if [ -z $1 ]; then
    echo "-i to add new phone contact"
    echo "-v to view all contacts"
    echo "-s to search for phone record"
    echo "-e to delete all phone contacts"
    echo "-d to delete one contact"
    echo "-u to edit a contact"
    echo "-n to sort contacts by name"
    echo "-g to group contacts by country code"
fi


if [[ $1 == *"-i"* ]]; then
    echo "Create a new Record"
    read -p "Enter First Name: " fName
    read -p "Enter Last Name: " lName
    read -p "Enter Country: " country

    # Loop until a valid phone number with 10 digits is entered
    while true; do
        read -p "Enter phone number (10 digits only): " pNumber
        if [[ $pNumber =~ ^[0-9]{10}$ ]]; then
            # Fetch country code from the key-value pair based on the entered country
            country_code=${country_codes["$country"]}
            if [ -z "$country_code" ]; then
                echo "Country code not defined for $country"
                break
            fi
            
            # Add country code to the phone number
            pNumber="$country_code$pNumber"
            
            # Extract existing phone numbers from the database
            existing_numbers=$(awk '{print $3}' "$file")
            
            # Check if the phone number already exists in the database
            if grep -q "\<$pNumber\>" <<< "$existing_numbers"; then
                echo "Phone number already exists in the database."
            else
                echo "$fName $lName $pNumber $country" >> database.txt
                echo "Record added successfully."
                break
            fi
        else
            echo "Please enter a valid 10-digit phone number."
        fi
    done
fi

if [[ $1 == *"-s"* ]]; then
    echo "Search a Record"
    read -p "Enter First or Last Name or phone number : " search
    found=$(grep $search $file)
    if [ -z "$found" ]; then
        echo "No Item found"
    else 
        grep $search $file | while read -r line ; do
            i=$[ $i +1 ]
            echo "$i $line"
        done
    fi
fi

if [[ $1 == *"-v"* ]]; then
    echo "Viewing all contacts list"
    cat $file | while read line ; do
        i=$[ $i +1 ]
        echo "$i $line"
    done
fi

if [[ $1 == *"-e"* ]]; then
    echo "Delete all contacts"
    > $file
fi

if [[ $1 == *"-d"* ]]; then
    file="database.txt"  # Set the file path
    echo "Search a Record"
    read -p "Enter First or Last Name or phone number of the record you want to delete: " search
    found=$(grep -n "$search" "$file")
    if [ -z "$found" ]; then
        echo "No item found"
    else
        echo "$found" | while IFS=: read -r lineNumber line; do
            echo "$lineNumber: $line"
        done
        read -p "Enter the line number you want to delete: " deleteNo
        sed -i "${deleteNo}d" "$file"
        echo "Record deleted successfully"
    fi
fi

if [[ $1 == *"-u"* ]]; then
    echo "Edit a Contact"
    read -p "Enter the index of the contact you want to edit: " editIndex
    contact=$(sed -n "${editIndex}p" database.txt)
    if [ -z "$contact" ]; then
        echo "Contact not found"
    else
        echo "Editing contact: $contact"
        read -p "Enter new First Name: " newFName
        read -p "Enter new Last Name: " newLName
        read -p "Enter new phone number: " newPNumber
        read -p "Enter new Country: " newCountry

        # Fetch country code from the key-value pair based on the entered country
        country_code=${country_codes["$newCountry"]}
        if [ -z "$country_code" ]; then
            echo "Country code not defined for $newCountry"
        else
            newPNumber="$country_code$newPNumber"
            sed -i "${editIndex}s/.*/$newFName $newLName $newPNumber $newCountry/" database.txt
            echo "Contact updated successfully"
        fi
    fi
fi

if [[ $1 == *"-n"* ]]; then
    echo "Sorting contacts by name..."
    sort -o database.txt database.txt
    echo "Contacts sorted by name."
fi

if [[ $1 == *"-g"* ]]; then
    echo "Grouping contacts by country code:"
    # Iterate over each country code
    for code in "${!country_codes[@]}"; do
        echo "Country: $code (${country_codes[$code]})"
        # Use grep to filter contacts with the current country code
        grep "${country_codes[$code]}" "$file" | while read -r line; do
            echo "$line"
        done
        echo "---------------------"
    done
fi
