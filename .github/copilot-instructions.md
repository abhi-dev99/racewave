<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->

# F1 Strategy Hub - Copilot Instructions

This is a Flutter application for Formula 1 strategy simulation and driver performance analysis.

## Project Context

- **Framework**: Flutter 3.0+ with Dart
- **Architecture**: Clean architecture with separation of concerns
- **State Management**: Provider pattern for state management
- **API Integration**: Ergast F1 API for real-time F1 data
- **UI Design**: Material Design 3 with F1-themed color scheme

## Coding Guidelines

### Flutter-Specific
- Use `const` constructors wherever possible for performance
- Follow Flutter naming conventions (camelCase for variables, PascalCase for classes)
- Use proper widget lifecycle methods (initState, dispose, etc.)
- Implement error handling for API calls and network operations
- Use `StatefulWidget` for dynamic content, `StatelessWidget` for static content

### State Management
- Use Provider for state management across the app
- Create separate providers for different data domains (drivers, races, standings)
- Implement proper loading states and error handling in providers
- Use `Consumer` widgets to listen to state changes

### API Integration
- All API calls should be handled in the `F1ApiService` class
- Implement proper error handling and timeout configurations
- Use JSON serialization with `json_annotation` for model classes
- Cache frequently accessed data using `SharedPreferences`

### UI/UX Guidelines
- Maintain consistent spacing using predefined values (8, 16, 20, 24px)
- Use F1 red (#E10600) as the primary color theme
- Implement proper loading indicators and error states
- Follow Material Design 3 principles
- Ensure responsive design for different screen sizes

### Code Organization
- Keep models in `lib/models/` directory
- Place screens in `lib/screens/` directory
- Put services in `lib/services/` directory
- Use descriptive file and class names
- Add proper documentation comments for public methods

### Performance Considerations
- Use `ListView.builder` for large lists
- Implement proper image caching for driver photos
- Use `const` widgets to reduce rebuilds
- Implement pagination for large datasets
- Use `RefreshIndicator` for pull-to-refresh functionality

### F1-Specific Features
- When working with F1 data, always consider:
  - Driver numbers and codes
  - Team affiliations and colors
  - Circuit characteristics and layouts
  - Tire compound strategies (Soft/Medium/Hard)
  - Weather impact on race strategy
  - Points system and championship calculations

### Testing
- Write unit tests for service classes
- Test API integration with mock data
- Implement widget tests for critical UI components
- Test different device orientations and screen sizes

## Development Workflow

1. Always run `flutter analyze` before committing
2. Use `flutter test` to run all tests
3. Format code with `flutter format`
4. Generate JSON serialization with `flutter packages pub run build_runner build`
5. Test on both Android and iOS platforms when possible

## Error Handling Patterns

```dart
try {
  // API call or operation
  final result = await apiService.getData();
  setState(() {
    data = result;
    isLoading = false;
  });
} catch (e) {
  setState(() {
    error = e.toString();
    isLoading = false;
  });
  // Log error for debugging
  print('Error: $e');
}
```

## Common F1 Data Structures

- Drivers: ID, name, nationality, team, number, code
- Races: Round, name, circuit, date, time, location
- Standings: Position, points, wins, driver info, team info
- Circuits: Name, location, coordinates, country

When suggesting code improvements or new features, prioritize:
1. User experience and intuitive navigation
2. Real-time data accuracy and freshness
3. Performance optimization
4. F1 domain knowledge and accuracy
5. Accessibility and inclusive design
