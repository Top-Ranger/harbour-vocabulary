Name:       harbour-vocabulary

# >> macros
# << macros

%{!?qtc_qmake:%define qtc_qmake %qmake}
%{!?qtc_qmake5:%define qtc_qmake5 %qmake5}
%{!?qtc_make:%define qtc_make make}
%{?qtc_builddir:%define _builddir %qtc_builddir}
Summary:    Vocabulary trainer for SailfishOS
Version:    1.2
Release:    1
Group:      Qt/Qt
License:    Apache-2.0
URL:        https://github.com/Top-Ranger/harbour-vocabulary
Source0:    %{name}-%{version}.tar.bz2
Requires:   sailfishsilica-qt5 >= 0.10.9
BuildRequires:  pkgconfig(Qt5Quick)
BuildRequires:  pkgconfig(Qt5Qml)
BuildRequires:  pkgconfig(Qt5Core)
BuildRequires:  pkgconfig(sailfishapp) >= 0.0.10

%description
Vocabulary is a vocabulary trainer for SailfishOS designed to be used independent of the language you want to learn.

%prep
%setup -q -n %{name}-%{version}

# >> setup
# << setup

%build
# >> build pre
# << build pre

%qtc_qmake5 

%qtc_make %{?_smp_mflags}

# >> build post
# << build post

%install
rm -rf %{buildroot}
# >> install pre
# << install pre
%qmake5_install

# >> install post
# << install post

%files
%defattr(-,root,root,-)
%{_bindir}
%{_datadir}/%{name}/
%{_datadir}/applications
%{_datadir}/icons/hicolor/86x86/apps
%{_datadir}/icons/hicolor/108x108/apps
%{_datadir}/icons/hicolor/128x128/apps
%{_datadir}/icons/hicolor/256x256/apps
# >> files
# << files
