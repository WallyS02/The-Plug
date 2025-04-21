from django.views.decorators.cache import cache_page
from functools import wraps


def dynamic_cache_page(timeout, key_prefix_func):
    def decorator(view_func):
        @wraps(view_func)
        def _wrapped_view(request, *args, **kwargs):
            key_prefix = key_prefix_func(request, *args, **kwargs)
            view_func_cached = cache_page(timeout, key_prefix=key_prefix)(view_func)
            return view_func_cached(request, *args, **kwargs)

        return _wrapped_view

    return decorator