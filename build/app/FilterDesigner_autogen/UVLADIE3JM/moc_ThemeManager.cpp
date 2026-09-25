/****************************************************************************
** Meta object code from reading C++ file 'ThemeManager.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.4.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../../../app/src/ThemeManager.h"
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'ThemeManager.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 68
#error "This file was generated using the moc from 6.4.2. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

#ifndef Q_CONSTINIT
#define Q_CONSTINIT
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
namespace {
struct qt_meta_stringdata_ThemeManager_t {
    uint offsetsAndSizes[44];
    char stringdata0[13];
    char stringdata1[17];
    char stringdata2[1];
    char stringdata3[10];
    char stringdata4[7];
    char stringdata5[11];
    char stringdata6[8];
    char stringdata7[12];
    char stringdata8[12];
    char stringdata9[14];
    char stringdata10[12];
    char stringdata11[7];
    char stringdata12[12];
    char stringdata13[9];
    char stringdata14[10];
    char stringdata15[10];
    char stringdata16[14];
    char stringdata17[7];
    char stringdata18[10];
    char stringdata19[7];
    char stringdata20[6];
    char stringdata21[5];
};
#define QT_MOC_LITERAL(ofs, len) \
    uint(sizeof(qt_meta_stringdata_ThemeManager_t::offsetsAndSizes) + ofs), len 
Q_CONSTINIT static const qt_meta_stringdata_ThemeManager_t qt_meta_stringdata_ThemeManager = {
    {
        QT_MOC_LITERAL(0, 12),  // "ThemeManager"
        QT_MOC_LITERAL(13, 16),  // "themeModeChanged"
        QT_MOC_LITERAL(30, 0),  // ""
        QT_MOC_LITERAL(31, 9),  // "themeMode"
        QT_MOC_LITERAL(41, 6),  // "isDark"
        QT_MOC_LITERAL(48, 10),  // "background"
        QT_MOC_LITERAL(59, 7),  // "surface"
        QT_MOC_LITERAL(67, 11),  // "surfaceHigh"
        QT_MOC_LITERAL(79, 11),  // "primaryText"
        QT_MOC_LITERAL(91, 13),  // "secondaryText"
        QT_MOC_LITERAL(105, 11),  // "borderColor"
        QT_MOC_LITERAL(117, 6),  // "accent"
        QT_MOC_LITERAL(124, 11),  // "accentMuted"
        QT_MOC_LITERAL(136, 8),  // "plotGrid"
        QT_MOC_LITERAL(145, 9),  // "plotCurve"
        QT_MOC_LITERAL(155, 9),  // "sidebarBg"
        QT_MOC_LITERAL(165, 13),  // "activityBarBg"
        QT_MOC_LITERAL(179, 6),  // "danger"
        QT_MOC_LITERAL(186, 9),  // "ThemeMode"
        QT_MOC_LITERAL(196, 6),  // "System"
        QT_MOC_LITERAL(203, 5),  // "Light"
        QT_MOC_LITERAL(209, 4)   // "Dark"
    },
    "ThemeManager",
    "themeModeChanged",
    "",
    "themeMode",
    "isDark",
    "background",
    "surface",
    "surfaceHigh",
    "primaryText",
    "secondaryText",
    "borderColor",
    "accent",
    "accentMuted",
    "plotGrid",
    "plotCurve",
    "sidebarBg",
    "activityBarBg",
    "danger",
    "ThemeMode",
    "System",
    "Light",
    "Dark"
};
#undef QT_MOC_LITERAL
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_ThemeManager[] = {

 // content:
      10,       // revision
       0,       // classname
       0,    0, // classinfo
       1,   14, // methods
      15,   21, // properties
       1,   96, // enums/sets
       0,    0, // constructors
       0,       // flags
       1,       // signalCount

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       1,    0,   20,    2, 0x06,   16 /* Public */,

 // signals: parameters
    QMetaType::Void,

 // properties: name, type, flags
       3, QMetaType::Int, 0x00015103, uint(0), 0,
       4, QMetaType::Bool, 0x00015001, uint(0), 0,
       5, QMetaType::QString, 0x00015001, uint(0), 0,
       6, QMetaType::QString, 0x00015001, uint(0), 0,
       7, QMetaType::QString, 0x00015001, uint(0), 0,
       8, QMetaType::QString, 0x00015001, uint(0), 0,
       9, QMetaType::QString, 0x00015001, uint(0), 0,
      10, QMetaType::QString, 0x00015001, uint(0), 0,
      11, QMetaType::QString, 0x00015001, uint(0), 0,
      12, QMetaType::QString, 0x00015001, uint(0), 0,
      13, QMetaType::QString, 0x00015001, uint(0), 0,
      14, QMetaType::QString, 0x00015001, uint(0), 0,
      15, QMetaType::QString, 0x00015001, uint(0), 0,
      16, QMetaType::QString, 0x00015001, uint(0), 0,
      17, QMetaType::QString, 0x00015001, uint(0), 0,

 // enums: name, alias, flags, count, data
      18,   18, 0x0,    3,  101,

 // enum data: key, value
      19, uint(ThemeManager::System),
      20, uint(ThemeManager::Light),
      21, uint(ThemeManager::Dark),

       0        // eod
};

Q_CONSTINIT const QMetaObject ThemeManager::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_ThemeManager.offsetsAndSizes,
    qt_meta_data_ThemeManager,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_stringdata_ThemeManager_t,
        // property 'themeMode'
        QtPrivate::TypeAndForceComplete<int, std::true_type>,
        // property 'isDark'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'background'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'surface'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'surfaceHigh'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'primaryText'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'secondaryText'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'borderColor'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'accent'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'accentMuted'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'plotGrid'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'plotCurve'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'sidebarBg'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'activityBarBg'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // property 'danger'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<ThemeManager, std::true_type>,
        // method 'themeModeChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>
    >,
    nullptr
} };

void ThemeManager::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<ThemeManager *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->themeModeChanged(); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (ThemeManager::*)();
            if (_t _q_method = &ThemeManager::themeModeChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
    }else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<ThemeManager *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< int*>(_v) = _t->themeMode(); break;
        case 1: *reinterpret_cast< bool*>(_v) = _t->isDark(); break;
        case 2: *reinterpret_cast< QString*>(_v) = _t->background(); break;
        case 3: *reinterpret_cast< QString*>(_v) = _t->surface(); break;
        case 4: *reinterpret_cast< QString*>(_v) = _t->surfaceHigh(); break;
        case 5: *reinterpret_cast< QString*>(_v) = _t->primaryText(); break;
        case 6: *reinterpret_cast< QString*>(_v) = _t->secondaryText(); break;
        case 7: *reinterpret_cast< QString*>(_v) = _t->borderColor(); break;
        case 8: *reinterpret_cast< QString*>(_v) = _t->accent(); break;
        case 9: *reinterpret_cast< QString*>(_v) = _t->accentMuted(); break;
        case 10: *reinterpret_cast< QString*>(_v) = _t->plotGrid(); break;
        case 11: *reinterpret_cast< QString*>(_v) = _t->plotCurve(); break;
        case 12: *reinterpret_cast< QString*>(_v) = _t->sidebarBg(); break;
        case 13: *reinterpret_cast< QString*>(_v) = _t->activityBarBg(); break;
        case 14: *reinterpret_cast< QString*>(_v) = _t->danger(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
        auto *_t = static_cast<ThemeManager *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setThemeMode(*reinterpret_cast< int*>(_v)); break;
        default: break;
        }
    } else if (_c == QMetaObject::ResetProperty) {
    } else if (_c == QMetaObject::BindableProperty) {
    }
    (void)_a;
}

const QMetaObject *ThemeManager::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *ThemeManager::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_ThemeManager.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int ThemeManager::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 1)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 1;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 1)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 1;
    }else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 15;
    }
    return _id;
}

// SIGNAL 0
void ThemeManager::themeModeChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
