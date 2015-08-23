#include <hx/CFFI.h>
#include <system/System.h>
#include <utils/ByteArray.h>
#include <string>


namespace lime {
	
	
	AutoGCRoot *gByteArrayCreate = 0;
	AutoGCRoot *gByteArrayLen = 0;
	AutoGCRoot *gByteArrayResize = 0;
	AutoGCRoot *gByteArrayBytes = 0;
	
	
	ByteArray::ByteArray (int inSize) {
		
		mValue = val_call1 (gByteArrayCreate->get (), alloc_int (inSize));
		
	}
	
	
	ByteArray::ByteArray () : mValue(0) {
		
		
		
	}
	
	
	ByteArray::ByteArray (const QuickVec<uint8> &inData) {
		
		mValue = val_call1 (gByteArrayCreate->get (), alloc_int (inData.size ()));
		uint8 *bytes = Bytes ();
		if (bytes)
			memcpy (bytes, &inData[0], inData.size ());
		
	}
	
	
	ByteArray::ByteArray (const ByteArray &inRHS) : mValue (inRHS.mValue) {
		
		
		
	}
	
	
	ByteArray::ByteArray (value inValue) : mValue (inValue) {
		
		
		
	}
	
	
	ByteArray::ByteArray (const OSChar *inFilename) {
		
		FILE_HANDLE *file = lime::fopen (inFilename, "rb");
		
		if (!file) {
			
			//#ifdef ANDROID
			//return AndroidGetAssetBytes(inFilename);
			//#endif
			return;
			
		}
		
		lime::fseek (file, 0, SEEK_END);
		int len = lime::ftell (file);
		lime::fseek (file, 0, SEEK_SET);
		
		mValue = val_call1 (gByteArrayCreate->get (), alloc_int (len));
		
		int status = lime::fread (Bytes (), len, 1, file);
		lime::fclose (file);
		
	}
	
	
	void ByteArray::Resize (int inSize) {
		
		if (mValue == 0)
			mValue = val_call1 (gByteArrayCreate->get (), alloc_int (inSize));
		else
			val_call2 (gByteArrayResize->get (), mValue, alloc_int (inSize));
		
	}
	
	
	int ByteArray::Size () const {
		
		return val_int (val_call1 (gByteArrayLen->get (), mValue));
		
	}
	
	
	const unsigned char *ByteArray::Bytes () const {
		
		value bytes = val_call1 (gByteArrayBytes->get (), mValue);
		
		if (val_is_string (bytes))
			return (unsigned char *)val_string (bytes);
		
		buffer buf = val_to_buffer (bytes);
		
		if (buf == 0) {
			
			val_throw (alloc_string ("Bad ByteArray"));
		}
		
		return (unsigned char *)buffer_data (buf);
		
	}
	
	
	unsigned char *ByteArray::Bytes () {
		
		value bytes = val_call1 (gByteArrayBytes->get (),mValue);
		
		if (val_is_string (bytes))
			return (unsigned char *)val_string (bytes);
		
		buffer buf = val_to_buffer (bytes);
		
		if (buf == 0) {
			
			val_throw (alloc_string ("Bad ByteArray"));
			
		}
		
		return (unsigned char *)buffer_data (buf);
		
	}
	
	
	value lime_byte_array_get_native_pointer (value inByteArray) {
		
		ByteArray bytes (inByteArray);
		
		if (!val_is_null (bytes.mValue)) {
			
			return alloc_float ((intptr_t)bytes.Bytes ());
			
		}
		
		return alloc_null ();
		
	}
	
	
	value lime_byte_array_init (value inFactory, value inLen, value inResize, value inBytes) {
		
		gByteArrayCreate = new AutoGCRoot (inFactory);
		gByteArrayLen = new AutoGCRoot (inLen);
		gByteArrayResize = new AutoGCRoot (inResize);
		gByteArrayBytes = new AutoGCRoot (inBytes);
		
		return alloc_null ();
		
	}
	
	
	value lime_byte_array_overwrite_file (value inFilename, value inBytes) {
		
		// file is created if it doesn't exist,
		// if it exists, it is truncated to zero
		FILE_HANDLE *file = lime::fopen (val_os_string (inFilename), "wb");
		
		if (!file) {
			
			#ifdef ANDROID
			// [todo]
			#endif
			return alloc_null();
			
		}
		
		ByteArray array (inBytes);
		
		// The function fwrite() writes nitems objects, each size bytes long, to the
		// stream pointed to by stream, obtaining them from the location given by
		// ptr.
		// fwrite(const void *restrict ptr, size_t size, size_t nitems, FILE *restrict stream);
		lime::fwrite (array.Bytes (), 1, array.Size (), file);
		
		lime::fclose (file);
		return alloc_null ();
		
	}
	
	
	value lime_byte_array_read_file (value inFilename) {
		
		ByteArray result = ByteArray (val_os_string(inFilename));
		
		return result.mValue;
		
	}
	
	
	
	
	DEFINE_PRIM (lime_byte_array_get_native_pointer, 1);
	DEFINE_PRIM (lime_byte_array_init, 4);
	DEFINE_PRIM (lime_byte_array_overwrite_file, 2);
	DEFINE_PRIM (lime_byte_array_read_file, 1);
	
	
}


extern "C" int lime_byte_array_register_prims () {

	return 0;

}
