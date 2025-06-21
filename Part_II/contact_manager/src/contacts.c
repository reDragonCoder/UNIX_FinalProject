#include <stdio.h>
#include <string.h>
#include "contacts.h"

void add_contact(const char* filename, Contact c) {
    FILE* f = fopen(filename, "ab");
    if (f == NULL) {
        perror("Error opening file");
        return;
    }
    fwrite(&c, sizeof(Contact), 1, f);
    fclose(f);
}

void list_contacts(const char* filename) {
    FILE* f = fopen(filename, "rb");
    if (f == NULL) {
        printf("No contacts found.\n");
        return;
    }

    Contact c;
    printf("\nContact List:\n");
    while (fread(&c, sizeof(Contact), 1, f)) {
        printf("Name: %s | Phone: %s\n", c.name, c.phone);
    }
    fclose(f);
}

int search_contact(const char* filename, const char* name) {
    FILE* f = fopen(filename, "rb");
    if (f == NULL) {
        return 0;
    }

    Contact c;
    while (fread(&c, sizeof(Contact), 1, f)) {
        if (strcmp(c.name, name) == 0) {
            printf("Found: %s - %s\n", c.name, c.phone);
            fclose(f);
            return 1;
        }
    }
    fclose(f);
    return 0;
}

int delete_contact(const char* filename, const char* name) {
    FILE* f = fopen(filename, "rb");
    if (f == NULL) return 0;

    FILE* temp = fopen("temp.dat", "wb");
    if (temp == NULL) return 0;

    Contact c;
    int found = 0;

    while (fread(&c, sizeof(Contact), 1, f)) {
        if (strcmp(c.name, name) == 0) {
            found = 1;
            continue;
        }
        fwrite(&c, sizeof(Contact), 1, temp);
    }

    fclose(f);
    fclose(temp);
    remove(filename);
    rename("temp.dat", filename);

    return found;
}
