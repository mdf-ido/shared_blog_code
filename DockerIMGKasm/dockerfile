FROM kasmweb/core:1.8.0
USER root

ENV HOME /home/kasm-default-profile
ENV STARTUPDIR /dockerstartup
ENV INST_SCRIPTS $STARTUPDIR/install
WORKDIR $HOME

######### Customize Container Here ###########

##Install Posh
RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb
RUN apt-get update && apt-get install -y powershell

#Install Citrix Workspace App
RUN apt-get update && apt-get install -y libwebkit2gtk-4.0-37
RUN curl https://downloads.citrix.com/16914/icaclient_19.12.0.19_amd64.deb?__gda__=1613901339_953019539b968104960cfc4a13be55b0 -o ctxwrkspace.deb \
    && dpkg -i ctxwrkspace.deb 

# Install Google Chrome
COPY ./src/ubuntu/install/chrome $INST_SCRIPTS/chrome/
RUN bash $INST_SCRIPTS/chrome/install_chrome.sh  && rm -rf $INST_SCRIPTS/chrome/

#Add background
RUN wget https://github.com/m05tr0-DevOps/KasmImages/blob/main/IMG_20201107_134647_Bokeh.jpg?raw=true -O $HOME/.config/bg_kasm.png


######### End Customizations ###########

RUN chown 1000:0 $HOME
RUN $STARTUPDIR/set_user_permission.sh $HOME

ENV HOME /home/kasm-user
WORKDIR $HOME
RUN mkdir -p $HOME && chown -R 1000:0 $HOME

USER 1000