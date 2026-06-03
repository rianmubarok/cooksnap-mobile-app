/**
 * CookSnap — Shared Tailwind CSS Configuration
 *
 * Loaded by every page in pb_public AFTER the Tailwind CDN script.
 * Centralises brand tokens so they only need to be updated here.
 */
tailwind.config = {
  theme: {
    extend: {
      fontFamily: {
        sans: ['"Work Sans"', 'sans-serif'],
      },
      colors: {
        cookgreen: {
          50:  '#f0fdf4',
          100: '#dcfce7',
          500: '#22c55e',
          600: '#16a34a',
          800: '#166534',
          900: '#143B16',
        },
        cooklime:   '#A7EE6A',
        cookorange: '#F58700',
      },
      letterSpacing: {
        tighter: '-0.04em',
        tight:   '-0.03em',
      },
      animation: {
        'fade-in':  'fadeIn 0.3s ease-out forwards',
        'slide-up': 'slideUp 0.4s ease-out forwards',
      },
      keyframes: {
        fadeIn: {
          '0%':   { opacity: '0' },
          '100%': { opacity: '1' },
        },
        slideUp: {
          '0%':   { opacity: '0', transform: 'translateY(20px)' },
          '100%': { opacity: '1', transform: 'translateY(0)' },
        },
      },
    },
  },
};
