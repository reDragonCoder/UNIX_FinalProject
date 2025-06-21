#ifndef CONTACTS_H
#define CONTACTS_H

#define MAX_NAME 50
#define MAX_PHONE 15

typedef struct {
    char name[MAX_NAME];
    char phone[MAX_PHONE];
} Contact;

void add_contact(const char* filename, Contact c);
void list_contacts(const char* filename);
int search_contact(const char* filename, const char* name);
int delete_contact(const char* filename, const char* name);

#endif
