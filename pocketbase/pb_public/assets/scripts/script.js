// Inisialisasi ikon Feather
feather.replace();

// Animasi Scroll Reveal
document.addEventListener('DOMContentLoaded', () => {
    // Jalankan reveal saat pertama kali dimuat
    revealElements();

    // Tambahkan event listener untuk scroll
    window.addEventListener('scroll', revealElements);

    // Efek Navbar saat scroll
    const navbar = document.getElementById('navbar');
    if (navbar) {
        window.addEventListener('scroll', () => {
            if (window.scrollY > 50) {
                navbar.style.boxShadow = '0 10px 25px rgba(0, 0, 0, 0.15)';
            } else {
                navbar.style.boxShadow = '';
            }
        });
    }
});

function revealElements() {
    const reveals = document.querySelectorAll('.reveal, .reveal-right');
    const windowHeight = window.innerHeight;
    const elementVisible = 100;

    reveals.forEach((element) => {
        const elementTop = element.getBoundingClientRect().top;
        if (elementTop < windowHeight - elementVisible) {
            element.classList.add('active');
        }
    });
}
