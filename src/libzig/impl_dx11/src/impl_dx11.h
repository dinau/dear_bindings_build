#pragma once

#define D3D11_NO_HELPERS
#define CINTERFACE
#define COBJMACROS
#define WIN32_LEAN_AND_MEAN
#include <d3d11.h>
#include <stdio.h>
#ifdef _MSC_VER
#include <windows.h>
#endif

#include <dxgi.h>
#include <stdbool.h>
#include "dcimgui.h"
#include "dcimgui_internal.h"
#include "dcimgui_impl_dx11.h"
