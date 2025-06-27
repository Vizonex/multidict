#ifndef _MULTIDICT_CAPSULE_H
#define _MULTIDICT_CAPSULE_H

#ifdef __cplusplus
extern "C" {
#endif

#define MULTIDICT_IMPL

#include <stdbool.h>

#include "../multidict_api.h"
#include "dict.h"
#include "hashtable.h"
#include "state.h"

static int
MultiDict_CheckOrException(void* state_, PyObject* self)
{
    if (!(MultiDict_Check(((mod_state*)state_), self))) {
        PyErr_Format(PyExc_TypeError,
                     "object should be a MultiDict instance not %s",
                     Py_TYPE(self)->tp_name);
        return 0;
    }
    return 1;
}

static PyTypeObject*
MultiDict_GetType(void* state_)
{
    mod_state* state = (mod_state*)state_;
    return (PyTypeObject*)Py_NewRef(state->MultiDictType);
}

static PyObject*
MultiDict_New(void* state_, int prealloc_size)
{
    mod_state* state = (mod_state*)state_;
    MultiDictObject* md = (MultiDictObject*)state->MultiDictType->tp_alloc(
        state->MultiDictType, 0);

    if (md == NULL) {
        return NULL;
    }
    if (md_init(md, state, false, prealloc_size) < 0) {
        Py_CLEAR(md);
        return NULL;
    }
    return (PyObject*)md;
}

static int
MultiDict_Add(void* state_, PyObject* self, PyObject* key, PyObject* value)
{
    return MultiDict_CheckOrException(state_, self)
               ? md_add((MultiDictObject*)self, key, value)
               : -1;
}

static int
MultiDict_Clear(void* state_, PyObject* self)
{
    // TODO: Macro for repeated steps being done?
    return MultiDict_CheckOrException(state_, self)
               ? md_clear((MultiDictObject*)self)
               : -1;
}

static int
MultiDict_SetDefault(void* state_, PyObject* self, PyObject* key,
                     PyObject* value, PyObject** result)
{
    return MultiDict_CheckOrException(state_, self)
               ? md_set_default((MultiDictObject*)self, key, value, result)
               : -1;
}

static int
MultiDict_Del(void* state_, PyObject* self, PyObject* key)
{
    return MultiDict_CheckOrException(state_, self)
               ? md_del((MultiDictObject*)self, key)
               : -1;
}

static uint64_t
MultiDict_Version(void* state_, PyObject* self)
{
    return MultiDict_CheckOrException(state_, self) &&
           md_version((MultiDictObject*)self);
}

static int
MultiDict_Contains(void* state_, PyObject* self, PyObject* key)
{
    return MultiDict_CheckOrException(state_, self)
               ? md_contains((MultiDictObject*)self, key, NULL)
               : -1;
};

// Suggestion: Would be smart in to do what python does and provide
// a version of GetOne, GetAll, PopOne & PopAll simillar
// to an unsafe call. The validation check could then be
// replaced with an assertion check such as _PyList_CAST for example
// a concept of this idea can be found for PyList_GetItem -> PyList_GET_ITEM

static int
MultiDict_GetOne(void* state_, PyObject* self, PyObject* key,
                 PyObject** result)
{
    return MultiDict_CheckOrException(state_, self)
               ? md_get_one((MultiDictObject*)self, key, result)
               : -1;
}

static int
MultiDict_GetAll(void* state_, PyObject* self, PyObject* key,
                 PyObject** result)
{
    return MultiDict_CheckOrException(state_, self)
               ? md_get_all((MultiDictObject*)self, key, result)
               : -1;
}

static int
MultiDict_PopOne(void* state_, PyObject* self, PyObject* key,
                 PyObject** result)
{
    return MultiDict_CheckOrException(state_, self)
               ? md_pop_one((MultiDictObject*)self, key, result)
               : -1;
}

static int
MultiDict_PopAll(void* state_, PyObject* self, PyObject* key,
                 PyObject** result)
{
    return MultiDict_CheckOrException(state_, self)
               ? md_pop_all((MultiDictObject*)self, key, result)
               : -1;
}

static PyObject*
MultiDict_PopItem(void* state_, PyObject* self)
{
    return MultiDict_CheckOrException(state_, self)
               ? md_pop_item((MultiDictObject*)self)
               : NULL;
}

static int
MultiDict_Replace(void* state_, PyObject* self, PyObject* key, PyObject* value)
{
    return MultiDict_CheckOrException(state_, self)
               ? md_replace((MultiDictObject*)self, key, value)
               : -1;
}

static int
MultiDict_UpdateFromMultiDict(void* state_, PyObject* self, PyObject* other,
                              bool update)
{
    return (MultiDict_CheckOrException(self, state_) &&
            MultiDict_CheckOrException(other, state_))
               ? md_update_from_ht(
                     (MultiDictObject*)self, (MultiDictObject*)other, update)
               : -1;
}

static int
MultiDict_UpdateFromDict(void* state_, PyObject* self, PyObject* kwds,
                         bool update)
{
    return MultiDict_CheckOrException(state_, self)
               ? md_update_from_dict((MultiDictObject*)self, kwds, update)
               : -1;
}

static int
MultiDict_UpdateFromSequence(void* state_, PyObject* self, PyObject* seq,
                             bool update)
{
    return MultiDict_CheckOrException(state_, self)
               ? md_update_from_seq((MultiDictObject*)self, seq, update)
               : -1;
}

static void
capsule_free(MultiDict_CAPI* capi)
{
    PyMem_Free(capi);
}

static void
capsule_destructor(PyObject* o)
{
    MultiDict_CAPI* capi = PyCapsule_GetPointer(o, MultiDict_CAPSULE_NAME);
    capsule_free(capi);
}

static PyObject*
new_capsule(mod_state* state)
{
    MultiDict_CAPI* capi =
        (MultiDict_CAPI*)PyMem_Malloc(sizeof(MultiDict_CAPI));
    if (capi == NULL) {
        PyErr_NoMemory();
        return NULL;
    }
    capi->state = state;
    capi->MultiDict_GetType = MultiDict_GetType;
    capi->MultiDict_New = MultiDict_New;
    capi->MultiDict_Add = MultiDict_Add;
    capi->MultiDict_Clear = MultiDict_Clear;
    capi->MultiDict_SetDefault = MultiDict_SetDefault;
    capi->MultiDict_Del = MultiDict_Del;
    capi->MultiDict_Version = MultiDict_Version;
    capi->MultiDict_Contains = MultiDict_Contains;
    capi->MultiDict_GetOne = MultiDict_GetOne;
    capi->MultiDict_GetAll = MultiDict_GetAll;
    capi->MultiDict_PopOne = MultiDict_PopOne;
    capi->MultiDict_PopAll = MultiDict_PopAll;
    capi->MultiDict_PopItem = MultiDict_PopItem;
    capi->MultiDict_Replace = MultiDict_Replace;
    capi->MultiDict_UpdateFromMultiDict = MultiDict_UpdateFromMultiDict;
    capi->MultiDict_UpdateFromDict = MultiDict_UpdateFromDict;
    capi->MultiDict_UpdateFromSequence = MultiDict_UpdateFromSequence;

    PyObject* ret =
        PyCapsule_New(capi, MultiDict_CAPSULE_NAME, capsule_destructor);
    if (ret == NULL) {
        capsule_free(capi);
    }
    return ret;
}

#ifdef __cplusplus
}
#endif

#endif