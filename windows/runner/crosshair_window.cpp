#include "crosshair_window.h"
#include <windows.h>
#include <cmath>

namespace {
constexpr int WINDOW_SIZE = 400;
constexpr COLORREF BACKGROUND_COLOR_KEY = RGB(0, 0, 0);
constexpr COLORREF CROSSHAIR_COLOR = RGB(255, 0, 0);

HWND g_hwnd = nullptr;
bool g_classRegistered = false;
double g_stroke = 3.0;
double g_length = 25.0;
double g_gap = 8.0;

const wchar_t* CLASS_NAME = L"FORESIGHT_CROSSHAIR";

LRESULT CALLBACK WindowProc(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam) {
  switch (uMsg) {
    case WM_PAINT: {
      PAINTSTRUCT ps;
      HDC hdc = BeginPaint(hwnd, &ps);

      RECT rect;
      GetClientRect(hwnd, &rect);

      // Fill background with transparent color
      HBRUSH bgBrush = CreateSolidBrush(BACKGROUND_COLOR_KEY);
      FillRect(hdc, &rect, bgBrush);
      DeleteObject(bgBrush);

      // Draw crosshair
      int centerX = (rect.right - rect.left) / 2;
      int centerY = (rect.bottom - rect.top) / 2;
      int halfGap = static_cast<int>(std::round(g_gap));
      int lineLen = static_cast<int>(std::round(g_length));
      int penWidth = static_cast<int>(std::round(g_stroke));
      penWidth = (penWidth < 1) ? 1 : (penWidth > 50 ? 50 : penWidth);

      HPEN pen = CreatePen(PS_SOLID, penWidth, CROSSHAIR_COLOR);
      HPEN oldPen = static_cast<HPEN>(SelectObject(hdc, pen));

      // Left line
      MoveToEx(hdc, centerX - halfGap - lineLen, centerY, nullptr);
      LineTo(hdc, centerX - halfGap, centerY);

      // Right line
      MoveToEx(hdc, centerX + halfGap, centerY, nullptr);
      LineTo(hdc, centerX + halfGap + lineLen, centerY);

      // Top line
      MoveToEx(hdc, centerX, centerY - halfGap - lineLen, nullptr);
      LineTo(hdc, centerX, centerY - halfGap);

      // Bottom line
      MoveToEx(hdc, centerX, centerY + halfGap, nullptr);
      LineTo(hdc, centerX, centerY + halfGap + lineLen);

      SelectObject(hdc, oldPen);
      DeleteObject(pen);

      EndPaint(hwnd, &ps);
      return 0;
    }
    case WM_DESTROY:
      if (g_hwnd == hwnd) {
        g_hwnd = nullptr;
      }
      return 0;
    default:
      return DefWindowProc(hwnd, uMsg, wParam, lParam);
  }
}

void RegisterWindowClass() {
  if (g_classRegistered) return;

  WNDCLASS wc = {};
  wc.lpfnWndProc = WindowProc;
  wc.hInstance = GetModuleHandle(nullptr);
  wc.lpszClassName = CLASS_NAME;
  wc.hbrBackground = CreateSolidBrush(BACKGROUND_COLOR_KEY);
  wc.hCursor = LoadCursor(nullptr, IDC_ARROW);
  wc.style = CS_HREDRAW | CS_VREDRAW;

  RegisterClass(&wc);
  g_classRegistered = true;
}

}  // namespace

extern "C" {

void crosshair_show(double stroke, double length, double gap) {
  if (g_hwnd != nullptr) {
    crosshair_update(stroke, length, gap);
    return;
  }

  RegisterWindowClass();

  g_stroke = stroke;
  g_length = length;
  g_gap = gap;

  int screenWidth = GetSystemMetrics(SM_CXSCREEN);
  int screenHeight = GetSystemMetrics(SM_CYSCREEN);
  int left = (screenWidth - WINDOW_SIZE) / 2;
  int top = (screenHeight - WINDOW_SIZE) / 2;

  HWND hwnd = CreateWindowEx(
      WS_EX_TRANSPARENT | WS_EX_LAYERED | WS_EX_TOPMOST,
      CLASS_NAME,
      L"ForesightCrosshair",
      WS_POPUP,
      left,
      top,
      WINDOW_SIZE,
      WINDOW_SIZE,
      nullptr,
      nullptr,
      GetModuleHandle(nullptr),
      nullptr);

  if (hwnd == nullptr) {
    return;
  }

  g_hwnd = hwnd;

  // Set transparent color
  SetLayeredWindowAttributes(g_hwnd, BACKGROUND_COLOR_KEY, 255, LWA_COLORKEY);

  ShowWindow(g_hwnd, SW_SHOW);
  SetWindowPos(g_hwnd, HWND_TOPMOST, left, top, WINDOW_SIZE, WINDOW_SIZE,
               SWP_SHOWWINDOW);

  UpdateWindow(g_hwnd);
}

void crosshair_hide() {
  if (g_hwnd == nullptr) return;

  DestroyWindow(g_hwnd);
  g_hwnd = nullptr;
}

void crosshair_update(double stroke, double length, double gap) {
  g_stroke = stroke;
  g_length = length;
  g_gap = gap;

  if (g_hwnd != nullptr) {
    InvalidateRect(g_hwnd, nullptr, FALSE);
  }
}

}  // extern "C"

