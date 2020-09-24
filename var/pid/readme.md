# Temperature Controller

## Standard format

### File Format

| Item              | Value | Description              |
|-------------------|-------|--------------------------|
| delimiter         |     , | The CSV delimiter        |
| decimal separator |     . | The Decimal Separator    |
| eol               |    \n | The End of Line          |

### Columns

| Name        | Unit | Unit Name | Minimum | Maximum | Description              |
|-------------|------|-----------|--------:|--------:|--------------------------|
| time        |    s | second    |       0 |         | The time variable        |
| control     |      |           |       0 |     255 | The control variable     |
| temperature |   °C | celsius   |         |         | The temperature variable |

### Length

Only the important section

### Folders

var +
    |
    + tc +
         |
         + raw
         |
         + standard