// Sample FSH file for manually testing the extension in Zed.
// Open this file in a Zed instance that has the dev extension installed.

Alias: $sct = http://snomed.info/sct

Profile: ZedPatient
Parent: Patient
Id: zed-patient
Title: "Zed Patient"
Description: "A patient profile used to smoke-test the FHIR Shorthand extension."
* identifier 1..* MS
* name 1..1
* gender from AdministrativeGender (required)
* birthDate obeys zed-birthdate-1

Invariant: zed-birthdate-1
Description: "Birth date must be in the past."
Severity: #error

Extension: ZedPreferredName
Id: zed-preferred-name
Title: "Preferred Name"
* value[x] only string

ValueSet: ZedContactRoles
Id: zed-contact-roles
* $sct#mother "Mother"
* $sct#father "Father"

Instance: ZedPatientExample
InstanceOf: ZedPatient
Usage: #example
* name.given = "Ada"
