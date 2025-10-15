# cython: language_level = 3, freethreading_compatible=True
from cpython.object cimport PyObject, PyTypeObject
from libc.stdint cimport uint64_t

cdef extern from *:
    """
/* Redefinition of dict.h */
#if PY_VERSION_HEX >= 0x030c00f0
#define MANAGED_WEAKREFS
#endif

typedef struct {
    PyObject_HEAD
#ifndef MANAGED_WEAKREFS
    PyObject *weaklist;
#endif
    void *state;
    Py_ssize_t used;
    uint64_t version;
    bool is_ci;
    htkeys_t *keys;
} MultiDictObject;

typedef struct {
    PyObject_HEAD
#ifndef MANAGED_WEAKREFS
    PyObject *weaklist;
#endif
    MultiDictObject *md;
} MultiDictProxyObject;

typedef struct {
    PyUnicodeObject str;
    PyObject *canonical;
    void *state;
} istrobject;
    """
     # Predefined objects from istr & multidict
    ctypedef struct MultiDictObject:
        pass
    
    ctypedef struct MultiDictProxyObject:
        pass
    
    ctypedef class multidict._multidict.MultiDict [object MultiDictObject, check_size ignore]:
        pass
    
    ctypedef class multidict._multidict.CIMultiDict [object MultiDictObject, check_size ignore]:
        pass
    
    ctypedef class multidict._multidict.MultiDictProxy [object MultiDictProxyObject, check_size ignore]:
        pass
    
    ctypedef class multidict._multidict.CIMultiDictProxy [object MultiDictProxyObject, check_size ignore]:
        pass

    ctypedef struct istrobject:
        pass 
        
    ctypedef class multidict._multidict.istr [object istrobject, check_size ignore]:
        pass



cdef extern from "multidict_api.h":
    """
#define MULTIDICT_IMPL
#define MULTIDICT_CYTHON_IMPL
    """
    # NOTE: Important that you import this 
    # After you've c-imported multidict 
    int multidict_import()
   
    enum _UpdateOp:
        Extend = 0
        Update = 1
        Merge = 2
    
    ctypedef _UpdateOp UpdateOp
    
    struct MultiDict_CAPI:
        void* state
        PyTypeObject * (*MultiDict_GetType)(void * state)
        PyObject * (*MultiDict_New)(void * state, int prealloc_size)
        int (*MultiDict_Add)(void * state, object self, object key, object value)
        int (*MultiDict_Clear)(void * state, object self)
        int (*MultiDict_SetDefault)(void * state, object self, object key, object default, PyObject ** result)
        int (*MultiDict_Del)(void * state, object self, object key)
        uint64_t (*MultiDict_Version)(void * state, object self)
        int (*MultiDict_Contains)(void * state, object self, object key)
        int (*MultiDict_GetOne)(void * state, object self, object key, PyObject ** result)
        int (*MultiDict_GetAll)(void * state, object self, object key, PyObject ** result)
        int (*MultiDict_PopOne)(void * state, object self, object key, PyObject ** result)
        int (*MultiDict_PopAll)(void * state, object self, object key, PyObject ** result)
        PyObject * (*MultiDict_PopItem)(void * state, object self)
        int (*MultiDict_Replace)(void * state, object self, object key, object value)
        int (*MultiDict_UpdateFromMultiDict)(void * state, object self, object other, UpdateOp op)
        int (*MultiDict_UpdateFromDict)(void * state, object self, object kwds, UpdateOp op)
        int (*MultiDict_UpdateFromSequence)(void * state, object self, object kwds, UpdateOp op)
        PyObject * (*MultiDictProxy_New)(void * state, object md)
        int (*MultiDictProxy_Contains)(void * state, object self, object key)
        int (*MultiDictProxy_GetAll)(void * state, object self, object key, PyObject ** result)
        int (*MultiDictProxy_GetOne)(void * state, object self, object key, PyObject ** result)
        PyTypeObject * (*MultiDictProxy_GetType)(void * state)
        PyObject * (*IStr_FromUnicode)(void * state, object str)
        PyObject * (*IStr_FromStringAndSize)(void * state, const char * str, Py_ssize_t size)
        PyObject * (*IStr_FromString)(void * state, const char * str)
        PyTypeObject * (*IStr_GetType)(void * state)
        PyTypeObject * (*CIMultiDict_GetType)(void * state)
        PyObject * (*CIMultiDict_New)(void * state, int prealloc_size)
        int (*CIMultiDict_Add)(void * state, object self, object key, object value)
        int (*CIMultiDict_Clear)(void * state, object self)
        int (*CIMultiDict_SetDefault)(void * state, object self, object key, object default, PyObject ** result)
        int (*CIMultiDict_Del)(void * state, object self, object key)
        uint64_t (*CIMultiDict_Version)(void * state, object self)
        int (*CIMultiDict_Contains)(void * state, object self, object key)
        int (*CIMultiDict_GetOne)(void * state, object self, object key, PyObject ** result)
        int (*CIMultiDict_GetAll)(void * state, object self, object key, PyObject ** result)
        int (*CIMultiDict_PopOne)(void * state, object self, object key, PyObject ** result)
        int (*CIMultiDict_PopAll)(void * state, object self, object key, PyObject ** result)
        PyObject * (*CIMultiDict_PopItem)(void * state, object self)
        int (*CIMultiDict_Replace)(void * state, object self, object key, object value)
        int (*CIMultiDict_UpdateFromMultiDict)(void * state, object self, object other, UpdateOp op)
        int (*CIMultiDict_UpdateFromDict)(void * state, object self, object kwds, UpdateOp op)
        int (*CIMultiDict_UpdateFromSequence)(void * state, object self, object kwds, UpdateOp op)
        PyObject * (*CIMultiDictProxy_New)(void * state, object md)
        int (*CIMultiDictProxy_Contains)(void * state, object self, object key)
        int (*CIMultiDictProxy_GetAll)(void * state, object self, object key, PyObject ** result)
        int (*CIMultiDictProxy_GetOne)(void * state, object self, object key, PyObject ** result)
        PyTypeObject * (*CIMultiDictProxy_GetType)(void * state)
        PyObject * (*MultiDictIter_New)(void * state, object self)
        int (*MultiDictIter_Next)(void * state, object self, PyObject ** key, PyObject ** value)
    
    
    MultiDict_CAPI * MultiDict_Import() except NULL
    int MultiDict_CheckExact(object op) except -1

    int MultiDict_Check(object op) except -1
    
    MultiDict MultiDict_New(int prealloc) # type: ignore
    
    int  MultiDict_Add(object self, object key, object value) except -1
    
    int  MultiDict_Clear(object self) except -1
    
    int  MultiDict_SetDefault(object self, object key, object default_, PyObject ** result) except -1
    
    int  MutliDict_Del(object self, object key) except -1
    
    uint64_t  MultiDict_Version(object self)
    
    int  MultiDict_Contains(object self, object key) except -1
    
    int  MultiDict_GetOne(object self, object key, PyObject ** result) except -1
    
    int  MultiDict_GetAll(object self, object key, PyObject ** result) except -1
    
    int  MultiDict_PopOne(object self, object key, PyObject ** result) except -1
    
    int  MultiDict_PopAll(object self, object key, PyObject ** result) except -1
    
    PyObject *  MultiDict_PopItem(object self) except NULL
    
    int  MultiDict_Replace(object self, object key, object value) except -1
    
    int  MultiDict_UpdateFromMultiDict(object self, object other, UpdateOp op) except -1
    
    int  MultiDict_UpdateFromDict(object self, object other, UpdateOp op) except -1
    
    int  MultiDict_UpdateFromSequence(object self, object seq, UpdateOp op) except -1
    
    PyObject *  MultiDictProxy_New(object md) except NULL
    
    int  MultiDictProxy_CheckExact(object op) except -1
    
    int  MultiDictProxy_Check(object op) except -1
    
    int  MultiDictProxy_Contains(object self, object key) except -1
    
    int  MultiDictProxy_GetAll(object self, object key, PyObject ** result) except -1
    
    int  MultiDictProxy_GetOne(object self, object key, PyObject ** result) except -1
    
    int IStr_CheckExact(object op) except -1
    
    int IStr_Check(object op) except -1
    
    istr IStr_FromUnicode(object str) # type: ignore
    istr IStr_FromStringAndSize(const char * str, Py_ssize_t size) # type: ignore
    istr IStr_FromString(const char * str) # type: ignore
    
    int  CIMultiDict_CheckExact(object op) except -1
    
    int  CIMultiDict_Check(object op) except -1
    
    CIMultiDict CIMultiDict_New(int prealloc_size) # type: ignore
 
    int  CIMultiDict_Add(object self, object key, object value) except -1
    
    int  CIMultiDict_Clear(object self) except -1
    
    int  CIMultiDict_SetDefault(object self, object key, object default_, PyObject ** result) except -1
    
    int  CIMutliDict_Del(object self, object key) except -1
    
    uint64_t  CIMultiDict_Version(object self)
    
    int  CIMultiDict_Contains(object self, object key) except -1
    
    int  CIMultiDict_GetOne(object self, object key, PyObject ** result) except -1
    
    int  CIMultiDict_GetAll(object self, object key, PyObject ** result) except -1
    
    int  CIMultiDict_PopOne(object self, object key, PyObject ** result) except -1
    
    int  CIMultiDict_PopAll(object self, object key, PyObject ** result) except -1
    
    PyObject *  CIMultiDict_PopItem(object self) except NULL
    
    int  CIMultiDict_Replace(object self, object key, object value) except -1
    
    int  CIMultiDict_UpdateFromMultiDict(object self, object other, UpdateOp op) except -1
    
    int  CIMultiDict_UpdateFromDict(object self, object other, UpdateOp op) except -1

    int  CIMultiDict_UpdateFromSequence(object self, object seq, UpdateOp op) except -1
    
    CIMultiDictProxy CIMultiDictProxy_New(object md) # type: ignore
    
    int  CIMultiDictProxy_CheckExact(object op) except -1
    
    int  CIMultiDictProxy_Check(object op) except -1
    
    int  CIMultiDictProxy_Contains(object self, object key) except -1
    
    int  CIMultiDictProxy_GetAll(object self, object key, PyObject ** result) except -1
    
    int  CIMultiDictProxy_GetOne(object self, object key, PyObject ** result) except -1
    

    object MultiDictIter_New(object md)
    int  MultiDictIter_Next(object self, PyObject ** key, PyObject ** value) except -1
    MultiDict_CAPI* MultiDict_API
