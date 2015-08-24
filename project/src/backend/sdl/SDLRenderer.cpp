#include "SDLWindow.h"
#include "SDLRenderer.h"
#include "../../graphics/opengl/OpenGLBindings.h"


namespace lime {
	
	
	SDLRenderer::SDLRenderer (Window* window) {
		
		currentWindow = window;
		sdlWindow = ((SDLWindow*)window)->sdlWindow;
		sdlTexture = 0;
		
		width = 0;
		height = 0;
		
		int sdlFlags = 0;
		
		if (window->flags & WINDOW_FLAG_HARDWARE) {
			
			sdlFlags |= SDL_RENDERER_ACCELERATED;
			
		} else {
			
			sdlFlags |= SDL_RENDERER_SOFTWARE;
			
		}
		
		if (window->flags & WINDOW_FLAG_VSYNC) sdlFlags |= SDL_RENDERER_PRESENTVSYNC;
		
		sdlRenderer = SDL_CreateRenderer (sdlWindow, -1, sdlFlags);
		
		if (!sdlRenderer) {
			
			printf ("Could not create SDL renderer: %s.\n", SDL_GetError ());
			
		}
		
		OpenGLBindings::Init ();
		
	}
	
	
	SDLRenderer::~SDLRenderer () {
		
		if (sdlRenderer) {
			
			SDL_DestroyRenderer (sdlRenderer);
			
		}
		
	}
	
	
	void SDLRenderer::Flip () {
		
		SDL_RenderPresent (sdlRenderer);
		
	}
	
	
	value SDLRenderer::Lock () {
		
		int width;
		int height;
		
		SDL_GetRendererOutputSize (sdlRenderer, &width, &height);
		
		if ( width != this->width || height != this->height) {
			
			if( sdlTexture )
				SDL_DestroyTexture( sdlTexture );
			
			sdlTexture = SDL_CreateTexture (sdlRenderer, SDL_PIXELFORMAT_ARGB8888, SDL_TEXTUREACCESS_STREAMING, width, height);
			
		}
		
		value result = alloc_empty_object ();
		
		void *pixels;
		int pitch;
		
		if (SDL_LockTexture (sdlTexture, NULL, &pixels, &pitch) == 0) {
			
			alloc_field (result, val_id ("width"), alloc_int (width));
			alloc_field (result, val_id ("height"), alloc_int (height));
			alloc_field (result, val_id ("pixels"), alloc_float ((intptr_t)pixels));
			alloc_field (result, val_id ("pitch"), alloc_int (pitch));
			
		}
		
		return result;
		
	}
	
	
	void SDLRenderer::Unlock () {
		
		if (sdlTexture) {
			
			SDL_UnlockTexture (sdlTexture);
			SDL_RenderClear (sdlRenderer);
			SDL_RenderCopy (sdlRenderer, sdlTexture, NULL, NULL);
			
		}
		
	}
	
	
	Renderer* CreateRenderer (Window* window) {
		
		return new SDLRenderer (window);
		
	}
	
	
}