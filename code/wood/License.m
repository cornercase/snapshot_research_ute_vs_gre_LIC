function varargout = License(varargin)
% LICENSE M-file for License.fig
%      LICENSE, by itself, creates a new LICENSE or raises the existing
%      singleton*.
%
%      H = LICENSE returns the handle to a new LICENSE or the handle to
%      the existing singleton*.
%
%      LICENSE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LICENSE.M with the given input arguments.
%
%      LICENSE('Property','Value',...) creates a new LICENSE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before License_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to License_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help License

% Last Modified by GUIDE v2.5 08-May-2011 10:05:09

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @License_OpeningFcn, ...
                   'gui_OutputFcn',  @License_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before License is made visible.
function License_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to License (see VARARGIN)

% Choose default command line output for License
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes License wait for user response (see UIRESUME)
% uiwait(handles.LicenseFigure);


% --- Outputs from this function are returned to the command line.
function varargout = License_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
strn1=sprintf('%s \n \n ','Iron Analysis 3 is an academic work produced by Dr. John Wood. It cannot be sold nor distributed by anyone other than Dr. Wood.');
strn2=sprintf('%s \n \n ', 'Use in academic work must be cited');
strn3=sprintf('%s \n \n ','The software has not undergo any review by health regulatory agencies and is provided "As Is", with no warranty.');
strn4=sprintf('%s \n \n ','The software is provided free of charge for academic use. License for nonacademic use can be obtained.');
set(handles.LicenseAgreement,'String',[strn1,strn2,strn3,strn4]);


% --- Executes on button press in Agree.
function Agree_Callback(hObject, eventdata, handles)
% hObject    handle to Agree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(handles.LicenseFigure)

% --- Executes on button press in Disagree.
function Disagree_Callback(hObject, eventdata, handles)
% hObject    handle to Disagree (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
exit

