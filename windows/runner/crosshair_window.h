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

// Update crosshair parameters with center dot option
CROSSHAIR_API void crosshair_update_full(double stroke, double length, double gap, int showCenter);

// Toggle crosshair window (show if hidden, hide if shown)
CROSSHAIR_API void crosshair_toggle();

#ifdef __cplusplus
}
#endif

#endif  // CROSSHAIR_WINDOW_H_

