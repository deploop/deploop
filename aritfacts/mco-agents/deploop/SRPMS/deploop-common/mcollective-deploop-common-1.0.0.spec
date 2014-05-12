Summary: Deploop Agent DDL
Name: mcollective-deploop-common
Version: 1.0.0
Release: 1
License: ASL 2.0
URL: https://github.com/deploop
Vendor: Redoop
Packager: Javi Roman <javiroman@redoop.org>
BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildArch: noarch
Group: System Tools
Source0: mcollective-deploop-common-1.0.0.tgz
Requires: mcollective-common >= 2.2.1

%description
Deploop Agent DDL for the The Hadoop Deploy System.

%prep
%setup

%build

%install
rm -rf %{buildroot}
%{__install} -d -m0755 %{buildroot}/usr/libexec/mcollective/mcollective/agent

%{__install} -m0644 usr/libexec/mcollective/mcollective/agent/deploop.ddl %{buildroot}/usr/libexec/mcollective/mcollective/agent/deploop.ddl

%files
%defattr(-,root,root,-)
/usr/libexec/mcollective/mcollective/agent/deploop.ddl

%changelog
* Thu Feb 21 2013 Javi Roman <javiroman@redoop.org> - 1.0.0-1
- Built Package mcollective-deploop-agent
