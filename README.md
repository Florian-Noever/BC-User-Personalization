# <img src="./assets/icon.svg" alt="" height="26"> BC Extended User Personalization

A lightweight Microsoft Dynamics 365 Business Central extension for exporting user page personalizations to JSON, importing selected personalizations, and transferring them between users or environments.

BC Extended User Personalization works with Business Central's standard **User Page Metadata** and does not require a custom persistent data store.

## Features

### User Personalization Overview

The **Extended User Personalization** page provides an overview of all enabled Business Central users.

It displays:

- User Security ID
- User Name
- Full Name

From this page, personalization data can be exported for individual users, a selection of users, or all enabled users.

### Export User Personalizations

Personalizations can be exported to a JSON file directly from Business Central.

The extension supports:

- Exporting a single user's personalizations
- Exporting personalizations for selected users
- Exporting personalizations for all enabled users

When exporting a single user, the generated file name includes the user's name and security ID.

For example:

```text
UserPersonalization_USERNAME_00000000-0000-0000-0000-000000000000.json
```

Exports containing multiple users use:

```text
UserPersonalization_MultipleUsers.json
```

The exported data is read from Business Central's standard **User Page Metadata** table.

### Import User Personalizations

Previously exported JSON files can be imported through the **Extended User Personalization** page.

After selecting a JSON file, the extension displays the contained personalized pages before applying any changes.

This allows individual pages to be included or excluded from the import.

### Selective Page Import

The **Extended User Personalization Import** page displays the pages contained in the imported personalization file.

For each page, it shows:

- Page ID
- Page Caption
- Whether the page should be imported

The page provides actions to:

- Check all pages
- Check selected pages
- Uncheck all pages
- Uncheck selected pages

Only pages that remain selected are included in the import.

This makes it possible to restore or transfer only specific page personalizations instead of replacing everything contained in an export.

### Import to the Current or Another User

After selecting the personalizations to import, the extension allows them to be applied to:

- The currently signed-in user
- A different Business Central user

When importing to another user, the standard Business Central **User Lookup** page is used to select the target user.

The user ID stored in the exported file does not determine the destination user. The selected target user receives the imported personalization records.

This makes the extension useful for copying page personalizations between users.

### Existing Personalizations

If personalization records already exist for the target user, the extension asks whether the existing records should be overwritten.

This provides an additional safeguard before replacing existing user personalization data.

### Open Personalized Pages

The **Open Personalized Pages** action opens Business Central's standard **Personalized Pages** page.

This provides quick access to the standard overview of personalized pages alongside the additional import and export functionality provided by the extension.

## Pages

### Extended User Personalization

| Property | Value |
| --- | --- |
| Object ID | `50100` |
| Object Name | `PTE User Personalization` |
| Caption | `Extended User Personalization` |
| Page Type | `List` |
| Source Table | `User` |
| Usage Category | `Administration` |

Only enabled users are displayed.

The page can be found using Business Central's **Tell Me** search with terms such as:

```text
Extended User Personalization
User Personalization
```

The page provides the following main actions:

- Import
- Download All
- Download Selection
- Open Personalized Pages

Individual users also provide a **Download** action directly from the list.

### Extended User Personalization Import

| Property | Value |
| --- | --- |
| Object ID | `50101` |
| Object Name | `PTE Extended User Perso Import` |
| Caption | `Extended User Personalization Import` |
| Page Type | `List` |
| Source Table | `PTE User Perso Visualizer Temp` |

This page is displayed during the import process and allows the user to select which personalized pages should be imported.

## Import and Export Format

Personalization data is exported as JSON.

The root of the JSON document contains the security IDs of the exported users. Each user contains a collection of records from Business Central's **User Page Metadata** table.

A simplified representation looks like:

```json
{
    "00000000-0000-0000-0000-000000000000": [
        {
            "1": "00000000-0000-0000-0000-000000000000",
            "2": "42",
            "...": "..."
        }
    ]
}
```

The numeric JSON properties correspond to field numbers in the standard Business Central table.

BLOB values contained in the personalization records are converted to text during export and restored during import.

## Standard Business Central Objects Used

The extension primarily relies on standard Business Central functionality:

```text
User
User Page Metadata
Page Metadata
Personalized Pages
User Lookup
Temp Blob
```

The actual personalization information is stored and maintained by Business Central.

The extension provides additional tooling for exporting, selecting, transferring, and importing that data.

## Temporary Import Data

The extension contains a temporary table:

```text
PTE User Perso Visualizer Temp
```

This table is used only to visualize the pages found in an imported personalization file and to track which pages should be imported.

The table has:

```al
TableType = Temporary;
```

No imported personalization data is permanently stored in this custom table.

## Use Cases

BC Extended User Personalization can be useful for administrators, developers, consultants, and support teams who need to:

- Back up a user's page personalizations
- Restore previously exported personalizations
- Copy personalizations from one user to another
- Transfer personalizations between compatible Business Central environments
- Apply only selected page personalizations
- Create a common personalization setup for multiple users
- Preserve user personalizations before making administrative changes
- Troubleshoot or migrate user-specific page configurations

## Installation

Download the [latest release](https://github.com/Florian-Noever/BC-User-Personalization/releases/latest) from the project's **GitHub Releases** page.

Each release is provided as a `.zip` archive containing the compiled Business Central `.app` package.

1. Download the `.zip` file from the latest GitHub release.
2. Extract the archive.
3. Locate the included `.app` file.
4. Publish and install the `.app` file in your Business Central environment.

### Business Central Online

Upload the extracted `.app` file through the **Extension Management** page in Business Central.

Open **Extension Management**, choose **Manage → Upload Extension**, select the `.app` file, and follow the installation dialog.

### Business Central On-Premises

For Business Central on-premises, use the extracted `.app` file with the Business Central Administration Shell or your environment's normal extension deployment process.

The extension must be published, synchronized, and installed before it becomes available to users.

## Permissions

Users need sufficient Business Central permissions to access the underlying user and personalization information.

In particular, users of the extension require access to:

- User information
- User Page Metadata
- Page Metadata
- User personalization information

Importing personalization data for other users should only be made available to trusted administrative or support users.

## Important Notes

User personalizations reference pages and metadata available in the Business Central environment.

When transferring personalization data between environments, the relevant pages and extensions should also exist in the target environment.

Personalizations created for pages or extensions that are unavailable or significantly different in the target environment might not be applicable.

Imports are performed in the context of the current Business Central company.

The extension does not maintain a separate personalization database. Exported JSON files contain data retrieved from Business Central's standard personalization records.

Care should be taken when sharing exported files because they can contain user identifiers and personalization metadata.

## Project Objects

The extension currently consists of the following objects:

| ID | Type | Object |
| ---: | --- | --- |
| `50100` | Page | `PTE User Personalization` |
| `50101` | Page | `PTE Extended User Perso Import` |
| `50100` | Table | `PTE User Perso Visualizer Temp` |
| `50100` | Codeunit | `PTE Export User Perso` |
| `50101` | Codeunit | `PTE Import User Perso` |

The same numeric ID can be used by different AL object types.

## Localization

The extension currently contains English strings together with German (`de-DE`) translations for its captions, tooltips, dialogs, and messages.

Examples include:

| English | German |
| --- | --- |
| Extended User Personalization | Erweiterte Benutzerpersonalisierung |
| Import | Importieren |
| Download All | Alles herunterladen |
| Download Selection | Auswahl herunterladen |
| Check All | Alle markieren |
| Uncheck All | Alle Markierungen aufheben |

## Contributing

Contributions, improvements, and bug reports are welcome.

When contributing code, please keep the extension focused on lightweight Business Central user personalization administration and avoid introducing unnecessary dependencies.

## Disclaimer

BC Extended User Personalization is an independent open-source Business Central extension and is not affiliated with or endorsed by Microsoft.

Microsoft Dynamics 365 Business Central is a trademark of Microsoft Corporation.
