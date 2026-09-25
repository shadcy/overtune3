/****************************************************************************
** Meta object code from reading C++ file 'SimulationModel.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.4.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../../../app/src/SimulationModel.h"
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'SimulationModel.h' doesn't include <QObject>."
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
struct qt_meta_stringdata_SimulationModel_t {
    uint offsetsAndSizes[46];
    char stringdata0[16];
    char stringdata1[12];
    char stringdata2[1];
    char stringdata3[14];
    char stringdata4[8];
    char stringdata5[8];
    char stringdata6[5];
    char stringdata7[8];
    char stringdata8[7];
    char stringdata9[13];
    char stringdata10[5];
    char stringdata11[11];
    char stringdata12[12];
    char stringdata13[14];
    char stringdata14[3];
    char stringdata15[3];
    char stringdata16[12];
    char stringdata17[10];
    char stringdata18[6];
    char stringdata19[12];
    char stringdata20[13];
    char stringdata21[8];
    char stringdata22[12];
};
#define QT_MOC_LITERAL(ofs, len) \
    uint(sizeof(qt_meta_stringdata_SimulationModel_t::offsetsAndSizes) + ofs), len 
Q_CONSTINIT static const qt_meta_stringdata_SimulationModel_t qt_meta_stringdata_SimulationModel = {
    {
        QT_MOC_LITERAL(0, 15),  // "SimulationModel"
        QT_MOC_LITERAL(16, 11),  // "dataChanged"
        QT_MOC_LITERAL(28, 0),  // ""
        QT_MOC_LITERAL(29, 13),  // "errorOccurred"
        QT_MOC_LITERAL(43, 7),  // "message"
        QT_MOC_LITERAL(51, 7),  // "loadWav"
        QT_MOC_LITERAL(59, 4),  // "path"
        QT_MOC_LITERAL(64, 7),  // "loadCsv"
        QT_MOC_LITERAL(72, 6),  // "column"
        QT_MOC_LITERAL(79, 12),  // "generateSine"
        QT_MOC_LITERAL(92, 4),  // "freq"
        QT_MOC_LITERAL(97, 10),  // "sampleRate"
        QT_MOC_LITERAL(108, 11),  // "durationSec"
        QT_MOC_LITERAL(120, 13),  // "generateChirp"
        QT_MOC_LITERAL(134, 2),  // "f0"
        QT_MOC_LITERAL(137, 2),  // "f1"
        QT_MOC_LITERAL(140, 11),  // "applyFilter"
        QT_MOC_LITERAL(152, 9),  // "enginePtr"
        QT_MOC_LITERAL(162, 5),  // "clear"
        QT_MOC_LITERAL(168, 11),  // "inputSignal"
        QT_MOC_LITERAL(180, 12),  // "outputSignal"
        QT_MOC_LITERAL(193, 7),  // "hasData"
        QT_MOC_LITERAL(201, 11)   // "signalLabel"
    },
    "SimulationModel",
    "dataChanged",
    "",
    "errorOccurred",
    "message",
    "loadWav",
    "path",
    "loadCsv",
    "column",
    "generateSine",
    "freq",
    "sampleRate",
    "durationSec",
    "generateChirp",
    "f0",
    "f1",
    "applyFilter",
    "enginePtr",
    "clear",
    "inputSignal",
    "outputSignal",
    "hasData",
    "signalLabel"
};
#undef QT_MOC_LITERAL
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_SimulationModel[] = {

 // content:
      10,       // revision
       0,       // classname
       0,    0, // classinfo
       9,   14, // methods
       4,  103, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       2,       // signalCount

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       1,    0,   68,    2, 0x06,    5 /* Public */,
       3,    1,   69,    2, 0x06,    6 /* Public */,

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
       5,    1,   72,    2, 0x02,    8 /* Public */,
       7,    2,   75,    2, 0x02,   10 /* Public */,
       7,    1,   80,    2, 0x22,   13 /* Public | MethodCloned */,
       9,    3,   83,    2, 0x02,   15 /* Public */,
      13,    4,   90,    2, 0x02,   19 /* Public */,
      16,    1,   99,    2, 0x02,   24 /* Public */,
      18,    0,  102,    2, 0x02,   26 /* Public */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,    4,

 // methods: parameters
    QMetaType::Void, QMetaType::QString,    6,
    QMetaType::Void, QMetaType::QString, QMetaType::Int,    6,    8,
    QMetaType::Void, QMetaType::QString,    6,
    QMetaType::Void, QMetaType::Double, QMetaType::Double, QMetaType::Double,   10,   11,   12,
    QMetaType::Void, QMetaType::Double, QMetaType::Double, QMetaType::Double, QMetaType::Double,   14,   15,   11,   12,
    QMetaType::Void, QMetaType::QObjectStar,   17,
    QMetaType::Void,

 // properties: name, type, flags
      19, QMetaType::QVariantList, 0x00015001, uint(0), 0,
      20, QMetaType::QVariantList, 0x00015001, uint(0), 0,
      21, QMetaType::Bool, 0x00015001, uint(0), 0,
      22, QMetaType::QString, 0x00015001, uint(0), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject SimulationModel::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_SimulationModel.offsetsAndSizes,
    qt_meta_data_SimulationModel,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_stringdata_SimulationModel_t,
        // property 'inputSignal'
        QtPrivate::TypeAndForceComplete<QVariantList, std::true_type>,
        // property 'outputSignal'
        QtPrivate::TypeAndForceComplete<QVariantList, std::true_type>,
        // property 'hasData'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // property 'signalLabel'
        QtPrivate::TypeAndForceComplete<QString, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<SimulationModel, std::true_type>,
        // method 'dataChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'errorOccurred'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'loadWav'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'loadCsv'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'loadCsv'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'generateSine'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        // method 'generateChirp'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        QtPrivate::TypeAndForceComplete<double, std::false_type>,
        // method 'applyFilter'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<QObject *, std::false_type>,
        // method 'clear'
        QtPrivate::TypeAndForceComplete<void, std::false_type>
    >,
    nullptr
} };

void SimulationModel::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<SimulationModel *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->dataChanged(); break;
        case 1: _t->errorOccurred((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 2: _t->loadWav((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 3: _t->loadCsv((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<int>>(_a[2]))); break;
        case 4: _t->loadCsv((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 5: _t->generateSine((*reinterpret_cast< std::add_pointer_t<double>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[3]))); break;
        case 6: _t->generateChirp((*reinterpret_cast< std::add_pointer_t<double>>(_a[1])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[2])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[3])),(*reinterpret_cast< std::add_pointer_t<double>>(_a[4]))); break;
        case 7: _t->applyFilter((*reinterpret_cast< std::add_pointer_t<QObject*>>(_a[1]))); break;
        case 8: _t->clear(); break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (SimulationModel::*)();
            if (_t _q_method = &SimulationModel::dataChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (SimulationModel::*)(const QString & );
            if (_t _q_method = &SimulationModel::errorOccurred; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 1;
                return;
            }
        }
    }else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<SimulationModel *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< QVariantList*>(_v) = _t->inputSignal(); break;
        case 1: *reinterpret_cast< QVariantList*>(_v) = _t->outputSignal(); break;
        case 2: *reinterpret_cast< bool*>(_v) = _t->hasData(); break;
        case 3: *reinterpret_cast< QString*>(_v) = _t->signalLabel(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
    } else if (_c == QMetaObject::ResetProperty) {
    } else if (_c == QMetaObject::BindableProperty) {
    }
}

const QMetaObject *SimulationModel::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *SimulationModel::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_SimulationModel.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int SimulationModel::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 9)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 9;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 9)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 9;
    }else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 4;
    }
    return _id;
}

// SIGNAL 0
void SimulationModel::dataChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void SimulationModel::errorOccurred(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 1, _a);
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
