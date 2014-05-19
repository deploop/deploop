tar cvzf ${HOME}/rpmbuild/SOURCES/mcollective-deploop-agent-1.0.0.tgz ../mcollective-deploop-agent-1.0.0/
tar cvzf ${HOME}/rpmbuild/SOURCES/mcollective-deploop-common-1.0.0.tgz ../mcollective-deploop-common-1.0.0/
cp deploop-agent/mcollective-deploop-agent-1.0.0.spec $HOME/rpmbuild/SPECS/mcollective-deploop-agent.spec
cp deploop-common/mcollective-deploop-common-1.0.0.spec $HOME/rpmbuild/SPECS/mcollective-deploop-common.spec

rpmbuild -ba ${HOME}/rpmbuild/SPECS/mcollective-deploop-agent.spec
rpmbuild -ba ${HOME}/rpmbuild/SPECS/mcollective-deploop-common.spec
