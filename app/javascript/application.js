// Menu Toggle
document.addEventListener('DOMContentLoaded', function() {
  const menuToggleBtn = document.getElementById('menuToggleBtn');
  const menuContent = document.getElementById('menuContent');
  const complianceDropdown = document.querySelector('.compliance-dropdown');

  if (menuToggleBtn && menuContent) {
    menuToggleBtn.addEventListener('click', function() {
      menuContent.classList.toggle('active');
    });
  }

  if (complianceDropdown) {
    let hideTimeout;

    complianceDropdown.addEventListener('mouseenter', function() {
      clearTimeout(hideTimeout);
      this.querySelector('.compliance-menu').classList.add('visible');
    });

    complianceDropdown.addEventListener('mouseleave', function() {
      const menu = this.querySelector('.compliance-menu');
      hideTimeout = setTimeout(function() {
        menu.classList.remove('visible');
      }, 200);
    });
  }

  // Mobile Menu
  const mobileMenuBtn = document.getElementById('mobileMenuBtn');
  const mobileMenuOverlay = document.getElementById('mobileMenuOverlay');
  const mobileMenuClose = document.getElementById('mobileMenuClose');

  const mobileComplianceBtn = document.getElementById('mobileComplianceBtn');
  const mobileComplianceOverlay = document.getElementById('mobileComplianceOverlay');
  const mobileComplianceClose = document.getElementById('mobileComplianceClose');

  if (mobileMenuBtn && mobileMenuOverlay) {
    mobileMenuBtn.addEventListener('click', function() {
      mobileMenuOverlay.classList.add('active');
    });
  }

  if (mobileMenuClose && mobileMenuOverlay) {
    mobileMenuClose.addEventListener('click', function() {
      mobileMenuOverlay.classList.remove('active');
    });
  }

  if (mobileMenuOverlay) {
    mobileMenuOverlay.addEventListener('click', function(e) {
      if (e.target === mobileMenuOverlay) {
        mobileMenuOverlay.classList.remove('active');
      }
    });
  }

  if (mobileComplianceBtn && mobileComplianceOverlay) {
    mobileComplianceBtn.addEventListener('click', function() {
      mobileComplianceOverlay.classList.add('active');
    });
  }

  if (mobileComplianceClose && mobileComplianceOverlay) {
    mobileComplianceClose.addEventListener('click', function() {
      mobileComplianceOverlay.classList.remove('active');
    });
  }

  if (mobileComplianceOverlay) {
    mobileComplianceOverlay.addEventListener('click', function(e) {
      if (e.target === mobileComplianceOverlay) {
        mobileComplianceOverlay.classList.remove('active');
      }
    });
  }

  // Mobile Search Toggle
  const mobileSearchToggle = document.getElementById('mobileSearchToggle');
  const mobileSearchBar = document.getElementById('mobileSearchBar');
  const mobileSearchClose = document.getElementById('mobileSearchClose');

  if (mobileSearchToggle && mobileSearchBar) {
    mobileSearchToggle.addEventListener('click', function() {
      mobileSearchBar.classList.add('active');
      mobileSearchBar.querySelector('input').focus();
    });
  }

  if (mobileSearchClose && mobileSearchBar) {
    mobileSearchClose.addEventListener('click', function() {
      mobileSearchBar.classList.remove('active');
    });
  }
});
