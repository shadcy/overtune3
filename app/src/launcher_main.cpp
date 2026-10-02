#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <shellapi.h>
#include <shlwapi.h>

#if defined(_MSC_VER)
#pragma comment(lib, "shlwapi.lib")
#pragma comment(lib, "shell32.lib")
#endif

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {
    (void)hInstance;
    (void)hPrevInstance;
    (void)lpCmdLine;
    (void)nCmdShow;

    WCHAR selfDir[MAX_PATH];
    GetModuleFileNameW(NULL, selfDir, MAX_PATH);
    PathRemoveFileSpecW(selfDir);

    WCHAR target[MAX_PATH];
    // Candidate 1: package root -> bin\ot3.exe
    wsprintfW(target, L"%s\\bin\\ot3.exe", selfDir);
    if (GetFileAttributesW(target) == INVALID_FILE_ATTRIBUTES) {
        // Candidate 2: package root -> bin\FilterDesigner.exe
        wsprintfW(target, L"%s\\bin\\FilterDesigner.exe", selfDir);
    }
    if (GetFileAttributesW(target) == INVALID_FILE_ATTRIBUTES) {
        // Candidate 3: already inside bin folder -> ot3.exe
        wsprintfW(target, L"%s\\ot3.exe", selfDir);
    }
    if (GetFileAttributesW(target) == INVALID_FILE_ATTRIBUTES) {
        // Candidate 4: already inside bin folder -> FilterDesigner.exe
        wsprintfW(target, L"%s\\FilterDesigner.exe", selfDir);
    }
    if (GetFileAttributesW(target) == INVALID_FILE_ATTRIBUTES) {
        // Candidate 5: build folder
        wsprintfW(target, L"%s\\build\\bin\\Release\\ot3.exe", selfDir);
    }

    if (GetFileAttributesW(target) == INVALID_FILE_ATTRIBUTES) {
        MessageBoxW(NULL,
            L"Unable to locate Overtune 3 executable (bin\\ot3.exe).\n\nPlease ensure the distribution package was extracted completely.",
            L"Overtune 3 Installer",
            MB_ICONERROR | MB_OK);
        return 1;
    }

    WCHAR workDir[MAX_PATH];
    lstrcpyW(workDir, target);
    PathRemoveFileSpecW(workDir);

    SHELLEXECUTEINFOW sei = { sizeof(sei) };
    sei.cbSize = sizeof(sei);
    sei.fMask = SEE_MASK_NOCLOSEPROCESS;
    sei.lpVerb = L"open";
    sei.lpFile = target;
    sei.lpParameters = L"--install";
    sei.lpDirectory = workDir;
    sei.nShow = SW_SHOWNORMAL;

    if (!ShellExecuteExW(&sei)) {
        MessageBoxW(NULL,
            L"Failed to launch Overtune 3 installer wizard.",
            L"Overtune 3 Installer",
            MB_ICONERROR | MB_OK);
        return 1;
    }

    return 0;
}
