#define SV_STRING(VALUE)                    newSVpv(VALUE,strlen(VALUE))
#define SV_CARRAY(VALUE,SIZE)               newSVpvn(VALUE,SIZE)
#define SV_UINT(VALUE)                      newSVuv(VALUE)
#define SV_INT(VALUE)                       newSViv(VALUE)
#define SV_DECIMAL(VALUE)                   newSVnv(VALUE)
#define SV_UNDEF_VAL                        newSV(0)
#define SV_UNDEF_REF                        &PL_sv_undef

#define HASH_STORE_UINT(HASH,KEY,VALUE)     hv_store(HASH,KEY,strlen(KEY),SV_UINT(VALUE),0)
#define HASH_STORE_INT(HASH,KEY,VALUE)      hv_store(HASH,KEY,strlen(KEY),SV_INT(VALUE),0)
//#define HASH_STORE_PTR(HASH,KEY,VALUE)    hv_store(HASH,KEY,strlen(KEY),PTR2IV(VALUE),0)
#define HASH_STORE_DECIMAL(HASH,KEY,VALUE)  hv_store(HASH,KEY,strlen(KEY),SV_DECIMAL(VALUE),0)
#define HASH_STORE_STRING(HASH,KEY,VALUE)   hv_store(HASH,KEY,strlen(KEY),SV_STRING(VALUE),0)
#define HASH_STORE_CARRAY(HASH,KEY,VAL,LEN) hv_store(HASH,KEY,strlen(KEY),SV_CARRAY(VAL,LEN),0)
#define HASH_STORE_SV(HASH,KEY,VALUE)       hv_store(HASH,KEY,strlen(KEY),VALUE,0)
#define HASH_FETCH_SCALAR(HASH,KEY)         hv_fetch(HASH,KEY,strlen(KEY),0)

#define PUSH(ARY,SV)                        av_push(ARY,SV)
#define SHIFT(ARY)                          av_shift(ARY)

#define MAKEREF(THING)                      newRV_inc((SV*)THING)
#define MAKEREF_NOINC(THING)                newRV_noinc((SV*)THING)
#define DR_HASHREF(SCALAR)                  (HV*)SvRV(SCALAR)

#define SV_RETAIN(REF)  										SvREFCNT_inc(REF)
#define SV_RELEASE(REF)											SvREFCNT_dec(REF)

#define SvGET_CSTR_FROM_HV(REF,KEY)					SvPV_nolen(*HASH_FETCH_SCALAR(REF, KEY))