# Fetch Recipe App

## Summary

The Recipe App displays a list of recipes fetched from a provided API endpoint. Each recipe shows its name, cuisine type, and photo. Users can:

- View a beautiful list of recipes with smooth animations
- Tap on any recipe to see more details
- Refresh the list at any time
- View recipe source websites and YouTube videos
- See appropriate empty states and error messages

## Focus Areas

I prioritized the following areas:

1. **Network Layer**: Implemented a robust networking layer with proper error handling and async/await
2. **Image Caching**: Custom disk caching solution for images to minimize network requests
3. **State Management**: Clear state handling for loading, empty, and error states
4. **UI/UX**: Beautiful animations, gradients, and smooth transitions
5. **Testing**: Comprehensive unit tests for core functionality

## Trade-offs and Decisions

1. **Custom Image Caching**: While implementing a custom disk cache was time-consuming, it was necessary to meet the requirements of not using URLSession's default cache.
2. **UI Complexity**: I chose to focus on making the UI polished but not overly complex to ensure all requirements were met first.
3. **Error Handling**: Implemented basic error handling that could be expanded with more specific error types in a production app.

## Weakest Part of the Project

The custom image caching implementation could be more robust with:

1. Cache expiration policies
2. Better handling of cache clearing
3. More sophisticated error recovery

## Additional Information

1. **Design Patterns Used**:
   - MVVM for architecture
   - Protocol-oriented programming for testability
   - Singleton pattern for the image loader 
   
2. **SwiftUI Features Used**:
   - AsyncImage (with custom implementation)
   - Animations and transitions
   - Custom gradients and modifiers
   - Environment objects for dependency injection

3. **Future Improvements**:
   - Add search/filter functionality
   - Implement favoriting/rating recipes
   - Add more detailed recipe information
  
