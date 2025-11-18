#ifndef CROSSHAIR_WINDOW_H_
#define CROSSHAIR_WINDOW_H_

#ifdef __cplusplus
extern "C" {
#endif

#ifdef _WIN32
#define CROSSHAIR_API __declspec(dllexport)
#else
#define CROSSHAIR_API
#endif

// Show crosshair window
CROSSHAIR_API void crosshair_show(double stroke, double length, double gap);

// Hide crosshair window
CROSSHAIR_API void crosshair_hide();

// Update crosshair parameters
CROSSHAIR_API void crosshair_update(double stroke, double length, double gap);

#ifdef __cplusplus
}
#endif

#endif  // CROSSHAIR_WINDOW_H_

