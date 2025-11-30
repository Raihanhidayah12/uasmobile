# Modernize CrudGuruPage Design

## Tasks
- [x] Remove AppBar and add _buildHeader() method similar to CrudSiswaPage but customized for guru (title "Kelola Data Guru", subtitle "Manage teacher data efficiently", icon Icons.person)
- [x] Update build method to use SafeArea, Column with header and Expanded list
- [x] Adjust list padding to match CrudSiswaPage (horizontal 16, vertical 24)
- [x] Add boxShadow to Card widgets for modern elevation effect
- [x] Update dialog title to remove emojis and match style (fontWeight bold, size 19)
- [x] Adjust dialog padding to vertical 29, horizontal 28
- [x] Update button styles (TextButton foregroundColor, ElevatedButton shape rounded 13, padding vertical 11 horizontal 20)
- [x] Wrap FloatingActionButton in gradient Container with shadow, set backgroundColor transparent, elevation 0, shape CircleBorder
- [x] Ensure all changes maintain functionality (no logic changes)
