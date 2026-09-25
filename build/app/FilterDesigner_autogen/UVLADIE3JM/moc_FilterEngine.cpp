/****************************************************************************
** Meta object code from reading C++ file 'FilterEngine.h'
**
** Created by: The Qt Meta Object Compiler version 68 (Qt 6.4.2)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include <memory>
#include "../../../../app/src/FilterEngine.h"
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'FilterEngine.h' doesn't include <QObject>."
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
struct qt_meta_stringdata_FilterEngine_t {
    uint offsetsAndSizes[52];
    char stringdata0[13];
    char stringdata1[12];
    char stringdata2[1];
    char stringdata3[15];
    char stringdata4[14];
    char stringdata5[8];
    char stringdata6[7];
    char stringdata7[11];
    char stringdata8[7];
    char stringdata9[15];
    char stringdata10[19];
    char stringdata11[11];
    char stringdata12[15];
    char stringdata13[6];
    char stringdata14[11];
    char stringdata15[11];
    char stringdata16[12];
    char stringdata17[9];
    char stringdata18[11];
    char stringdata19[14];
    char stringdata20[10];
    char stringdata21[15];
    char stringdata22[13];
    char stringdata23[12];
    char stringdata24[9];
    char stringdata25[11];
};
#define QT_MOC_LITERAL(ofs, len) \
    uint(sizeof(qt_meta_stringdata_FilterEngine_t::offsetsAndSizes) + ofs), len 
Q_CONSTINIT static const qt_meta_stringdata_FilterEngine_t qt_meta_stringdata_FilterEngine = {
    {
        QT_MOC_LITERAL(0, 12),  // "FilterEngine"
        QT_MOC_LITERAL(13, 11),  // "specChanged"
        QT_MOC_LITERAL(25, 0),  // ""
        QT_MOC_LITERAL(26, 14),  // "resultsChanged"
        QT_MOC_LITERAL(41, 13),  // "errorOccurred"
        QT_MOC_LITERAL(55, 7),  // "message"
        QT_MOC_LITERAL(63, 6),  // "design"
        QT_MOC_LITERAL(70, 10),  // "exportCode"
        QT_MOC_LITERAL(81, 6),  // "format"
        QT_MOC_LITERAL(88, 14),  // "filterTypeName"
        QT_MOC_LITERAL(103, 18),  // "filterResponseName"
        QT_MOC_LITERAL(122, 10),  // "filterType"
        QT_MOC_LITERAL(133, 14),  // "filterResponse"
        QT_MOC_LITERAL(148, 5),  // "order"
        QT_MOC_LITERAL(154, 10),  // "sampleRate"
        QT_MOC_LITERAL(165, 10),  // "cutoffFreq"
        QT_MOC_LITERAL(176, 11),  // "cutoffFreq2"
        QT_MOC_LITERAL(188, 8),  // "rippleDb"
        QT_MOC_LITERAL(197, 10),  // "stopbandDb"
        QT_MOC_LITERAL(208, 13),  // "magnitudeData"
        QT_MOC_LITERAL(222, 9),  // "phaseData"
        QT_MOC_LITERAL(232, 14),  // "groupDelayData"
        QT_MOC_LITERAL(247, 12),  // "poleZeroData"
        QT_MOC_LITERAL(260, 11),  // "impulseData"
        QT_MOC_LITERAL(272, 8),  // "stepData"
        QT_MOC_LITERAL(281, 10)   // "hasResults"
    },
    "FilterEngine",
    "specChanged",
    "",
    "resultsChanged",
    "errorOccurred",
    "message",
    "design",
    "exportCode",
    "format",
    "filterTypeName",
    "filterResponseName",
    "filterType",
    "filterResponse",
    "order",
    "sampleRate",
    "cutoffFreq",
    "cutoffFreq2",
    "rippleDb",
    "stopbandDb",
    "magnitudeData",
    "phaseData",
    "groupDelayData",
    "poleZeroData",
    "impulseData",
    "stepData",
    "hasResults"
};
#undef QT_MOC_LITERAL
} // unnamed namespace

Q_CONSTINIT static const uint qt_meta_data_FilterEngine[] = {

 // content:
      10,       // revision
       0,       // classname
       0,    0, // classinfo
       7,   14, // methods
      15,   67, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       3,       // signalCount

 // signals: name, argc, parameters, tag, flags, initial metatype offsets
       1,    0,   56,    2, 0x06,   16 /* Public */,
       3,    0,   57,    2, 0x06,   17 /* Public */,
       4,    1,   58,    2, 0x06,   18 /* Public */,

 // methods: name, argc, parameters, tag, flags, initial metatype offsets
       6,    0,   61,    2, 0x02,   20 /* Public */,
       7,    1,   62,    2, 0x02,   21 /* Public */,
       9,    0,   65,    2, 0x102,   23 /* Public | MethodIsConst  */,
      10,    0,   66,    2, 0x102,   24 /* Public | MethodIsConst  */,

 // signals: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,    5,

 // methods: parameters
    QMetaType::Void,
    QMetaType::QString, QMetaType::Int,    8,
    QMetaType::QString,
    QMetaType::QString,

 // properties: name, type, flags
      11, QMetaType::Int, 0x00015103, uint(0), 0,
      12, QMetaType::Int, 0x00015103, uint(0), 0,
      13, QMetaType::Int, 0x00015103, uint(0), 0,
      14, QMetaType::Double, 0x00015103, uint(0), 0,
      15, QMetaType::Double, 0x00015103, uint(0), 0,
      16, QMetaType::Double, 0x00015103, uint(0), 0,
      17, QMetaType::Double, 0x00015103, uint(0), 0,
      18, QMetaType::Double, 0x00015103, uint(0), 0,
      19, QMetaType::QVariantList, 0x00015001, uint(1), 0,
      20, QMetaType::QVariantList, 0x00015001, uint(1), 0,
      21, QMetaType::QVariantList, 0x00015001, uint(1), 0,
      22, QMetaType::QVariantList, 0x00015001, uint(1), 0,
      23, QMetaType::QVariantList, 0x00015001, uint(1), 0,
      24, QMetaType::QVariantList, 0x00015001, uint(1), 0,
      25, QMetaType::Bool, 0x00015001, uint(1), 0,

       0        // eod
};

Q_CONSTINIT const QMetaObject FilterEngine::staticMetaObject = { {
    QMetaObject::SuperData::link<QObject::staticMetaObject>(),
    qt_meta_stringdata_FilterEngine.offsetsAndSizes,
    qt_meta_data_FilterEngine,
    qt_static_metacall,
    nullptr,
    qt_incomplete_metaTypeArray<qt_meta_stringdata_FilterEngine_t,
        // property 'filterType'
        QtPrivate::TypeAndForceComplete<int, std::true_type>,
        // property 'filterResponse'
        QtPrivate::TypeAndForceComplete<int, std::true_type>,
        // property 'order'
        QtPrivate::TypeAndForceComplete<int, std::true_type>,
        // property 'sampleRate'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // property 'cutoffFreq'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // property 'cutoffFreq2'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // property 'rippleDb'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // property 'stopbandDb'
        QtPrivate::TypeAndForceComplete<double, std::true_type>,
        // property 'magnitudeData'
        QtPrivate::TypeAndForceComplete<QVariantList, std::true_type>,
        // property 'phaseData'
        QtPrivate::TypeAndForceComplete<QVariantList, std::true_type>,
        // property 'groupDelayData'
        QtPrivate::TypeAndForceComplete<QVariantList, std::true_type>,
        // property 'poleZeroData'
        QtPrivate::TypeAndForceComplete<QVariantList, std::true_type>,
        // property 'impulseData'
        QtPrivate::TypeAndForceComplete<QVariantList, std::true_type>,
        // property 'stepData'
        QtPrivate::TypeAndForceComplete<QVariantList, std::true_type>,
        // property 'hasResults'
        QtPrivate::TypeAndForceComplete<bool, std::true_type>,
        // Q_OBJECT / Q_GADGET
        QtPrivate::TypeAndForceComplete<FilterEngine, std::true_type>,
        // method 'specChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'resultsChanged'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'errorOccurred'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        QtPrivate::TypeAndForceComplete<const QString &, std::false_type>,
        // method 'design'
        QtPrivate::TypeAndForceComplete<void, std::false_type>,
        // method 'exportCode'
        QtPrivate::TypeAndForceComplete<QString, std::false_type>,
        QtPrivate::TypeAndForceComplete<int, std::false_type>,
        // method 'filterTypeName'
        QtPrivate::TypeAndForceComplete<QString, std::false_type>,
        // method 'filterResponseName'
        QtPrivate::TypeAndForceComplete<QString, std::false_type>
    >,
    nullptr
} };

void FilterEngine::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        auto *_t = static_cast<FilterEngine *>(_o);
        (void)_t;
        switch (_id) {
        case 0: _t->specChanged(); break;
        case 1: _t->resultsChanged(); break;
        case 2: _t->errorOccurred((*reinterpret_cast< std::add_pointer_t<QString>>(_a[1]))); break;
        case 3: _t->design(); break;
        case 4: { QString _r = _t->exportCode((*reinterpret_cast< std::add_pointer_t<int>>(_a[1])));
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 5: { QString _r = _t->filterTypeName();
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        case 6: { QString _r = _t->filterResponseName();
            if (_a[0]) *reinterpret_cast< QString*>(_a[0]) = std::move(_r); }  break;
        default: ;
        }
    } else if (_c == QMetaObject::IndexOfMethod) {
        int *result = reinterpret_cast<int *>(_a[0]);
        {
            using _t = void (FilterEngine::*)();
            if (_t _q_method = &FilterEngine::specChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 0;
                return;
            }
        }
        {
            using _t = void (FilterEngine::*)();
            if (_t _q_method = &FilterEngine::resultsChanged; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 1;
                return;
            }
        }
        {
            using _t = void (FilterEngine::*)(const QString & );
            if (_t _q_method = &FilterEngine::errorOccurred; *reinterpret_cast<_t *>(_a[1]) == _q_method) {
                *result = 2;
                return;
            }
        }
    }else if (_c == QMetaObject::ReadProperty) {
        auto *_t = static_cast<FilterEngine *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: *reinterpret_cast< int*>(_v) = _t->filterType(); break;
        case 1: *reinterpret_cast< int*>(_v) = _t->filterResponse(); break;
        case 2: *reinterpret_cast< int*>(_v) = _t->order(); break;
        case 3: *reinterpret_cast< double*>(_v) = _t->sampleRate(); break;
        case 4: *reinterpret_cast< double*>(_v) = _t->cutoffFreq(); break;
        case 5: *reinterpret_cast< double*>(_v) = _t->cutoffFreq2(); break;
        case 6: *reinterpret_cast< double*>(_v) = _t->rippleDb(); break;
        case 7: *reinterpret_cast< double*>(_v) = _t->stopbandDb(); break;
        case 8: *reinterpret_cast< QVariantList*>(_v) = _t->magnitudeData(); break;
        case 9: *reinterpret_cast< QVariantList*>(_v) = _t->phaseData(); break;
        case 10: *reinterpret_cast< QVariantList*>(_v) = _t->groupDelayData(); break;
        case 11: *reinterpret_cast< QVariantList*>(_v) = _t->poleZeroData(); break;
        case 12: *reinterpret_cast< QVariantList*>(_v) = _t->impulseData(); break;
        case 13: *reinterpret_cast< QVariantList*>(_v) = _t->stepData(); break;
        case 14: *reinterpret_cast< bool*>(_v) = _t->hasResults(); break;
        default: break;
        }
    } else if (_c == QMetaObject::WriteProperty) {
        auto *_t = static_cast<FilterEngine *>(_o);
        (void)_t;
        void *_v = _a[0];
        switch (_id) {
        case 0: _t->setFilterType(*reinterpret_cast< int*>(_v)); break;
        case 1: _t->setFilterResponse(*reinterpret_cast< int*>(_v)); break;
        case 2: _t->setOrder(*reinterpret_cast< int*>(_v)); break;
        case 3: _t->setSampleRate(*reinterpret_cast< double*>(_v)); break;
        case 4: _t->setCutoffFreq(*reinterpret_cast< double*>(_v)); break;
        case 5: _t->setCutoffFreq2(*reinterpret_cast< double*>(_v)); break;
        case 6: _t->setRippleDb(*reinterpret_cast< double*>(_v)); break;
        case 7: _t->setStopbandDb(*reinterpret_cast< double*>(_v)); break;
        default: break;
        }
    } else if (_c == QMetaObject::ResetProperty) {
    } else if (_c == QMetaObject::BindableProperty) {
    }
}

const QMetaObject *FilterEngine::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *FilterEngine::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_FilterEngine.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int FilterEngine::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 7)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 7;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 7)
            *reinterpret_cast<QMetaType *>(_a[0]) = QMetaType();
        _id -= 7;
    }else if (_c == QMetaObject::ReadProperty || _c == QMetaObject::WriteProperty
            || _c == QMetaObject::ResetProperty || _c == QMetaObject::BindableProperty
            || _c == QMetaObject::RegisterPropertyMetaType) {
        qt_static_metacall(this, _c, _id, _a);
        _id -= 15;
    }
    return _id;
}

// SIGNAL 0
void FilterEngine::specChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 0, nullptr);
}

// SIGNAL 1
void FilterEngine::resultsChanged()
{
    QMetaObject::activate(this, &staticMetaObject, 1, nullptr);
}

// SIGNAL 2
void FilterEngine::errorOccurred(const QString & _t1)
{
    void *_a[] = { nullptr, const_cast<void*>(reinterpret_cast<const void*>(std::addressof(_t1))) };
    QMetaObject::activate(this, &staticMetaObject, 2, _a);
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
