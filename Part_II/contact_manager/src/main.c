#include <stdio.h>
#include <string.h>
#include "contacts.h"

#define FILENAME "contacts.dat"

int main() {
    int option;
    Contact c;
    char name[MAX_NAME];

    while (1) {
        printf("\n1. Add contact\n2. List contacts\n3. Search contact\n4. Delete contact\n5. Exit\n");
        printf("Choose an option: ");
        scanf("%d", &option);
        getchar();  // clear newline character from buffer

        switch (option) {
            case 1:
                printf("Name: ");
                fgets(c.name, MAX_NAME, stdin);
                c.name[strcspn(c.name, "\n")] = 0;

                printf("Phone: ");
                fgets(c.phone, MAX_PHONE, stdin);
                c.phone[strcspn(c.phone, "\n")] = 0;

                add_contact(FILENAME, c);
                break;
            case 2:
                list_contacts(FILENAME);
                break;
            case 3:
                printf("Enter name to search: ");
                fgets(name, MAX_NAME, stdin);
                name[strcspn(name, "\n")] = 0;
                if (!search_contact(FILENAME, name)) {
                    printf("Contact not found.\n");
                }
                break;
            case 4:
                printf("Enter name to delete: ");
                fgets(name, MAX_NAME, stdin);
                name[strcspn(name, "\n")] = 0;
                if (delete_contact(FILENAME, name)) {
                    printf("Contact deleted.\n");
                } else {
                    printf("Contact not found.\n");
                }
                break;
            case 5:
                return 0;
            default:
                printf("Invalid option.\n");
        }
    }
}
