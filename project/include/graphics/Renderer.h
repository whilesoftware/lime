#ifndef LIME_GRAPHICS_RENDERER_H
#define LIME_GRAPHICS_RENDERER_H


#include <ui/Window.h>
#include <hx/CFFI.h>


namespace lime {
	
	
	class Renderer {
		
		
		public:
			
			virtual void Flip () = 0;
			virtual void* GetContext () = 0;
			virtual value Lock () = 0;
			virtual void MakeCurrent () = 0;
			virtual const char* Type () = 0;
			virtual void Unlock () = 0;
			
			Window* currentWindow;
		
		
	};
	
	
	Renderer* CreateRenderer (Window* window);
	
	
}


#endif