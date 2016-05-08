
function varargout = firstGUI(varargin) 
% FIRSTGUI MATLAB code for firstGUI.fig
%      FIRSTGUI, by itself, creates a new FIRSTGUI or raises the existing
%      singleton*.
%
%      H = FIRSTGUI returns the handle to a new FIRSTGUI or the handle to
%      the existing singleton*.
%
%      FIRSTGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIRSTGUI.M with the given input arguments.
%
%      FIRSTGUI('Property','Value',...) creates a new FIRSTGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before firstGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to firstGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help firstGUI

% Last Modified by GUIDE v2.5 05-Feb-2016 20:31:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @firstGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @firstGUI_OutputFcn, ...
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


% --- Executes just before firstGUI is made visible.
function firstGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to firstGUI (see VARARGIN)

% Choose default command line output for firstGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes firstGUI wait for user response (see UIRESUME)
% uiwait(handles.figure);
global img

% --- Outputs from this function are returned to the command line.
function varargout = firstGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes when figure is resized.
function figure_ResizeFcn(hObject, eventdata, handles)
% hObject    handle to figure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in START.
function START_Callback(hObject, eventdata, handles)
% hObject    handle to START (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global img
global filename
s = cell2mat(get(handles.table,'Data'));
if(nnz(s) ~= 8)
    msgbox('Please enter all numbers in table','ERROR          ');
else
    row = size(img,1);
    col = size(img,2);
    a1 = s';
    a1 = [a1(2,:);a1(1,:)];
    a2 = [ 1 1;1 col-1;row-1 1;row-1 col-1]';
    output = DirectLinearTransformation(a2,a1);
    msgbox('process started','MESSAGE');
    new_img1 = uint8(HomographyTransform( img(:,:,1), output , size(img(:,:,1))));
    fprintf('first channel\n');
    new_img2 = uint8(HomographyTransform( img(:,:,2), output , size(img(:,:,2))));
    fprintf('second channel\n');
    new_img3 = uint8(HomographyTransform( img(:,:,3), output , size(img(:,:,3))));
    fprintf('third channel\n');
    img(:,:,1) = new_img1;
    img(:,:,2) = new_img2;
    img(:,:,3) = new_img3;
    name = strcat('new_',filename);
    imwrite(img,name);
    msgbox('image saved','MESSAGE');
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

global img
global filename
s = num2cell([0 0;0 0;0 0;0 0]);
set(handles.table,'Data',s);

[filename, pathname] = uigetfile({'*.png;*.jpg;*.bmp;*.tif','Supported images';...
                 '*.png','Portable Network Graphics (*.png)';...
                 '*.jpg','J-PEG (*.jpg)';...
                 '*.bmp','Bitmap (*.bmp)';...
                 '*.tif','Tagged Image File (*.tif,)';...
                 '*.*','All files (*.*)'});
image = strcat(pathname,filename);
img = imread(image);
axes(handles.axes1);
imshow(image);


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
fprintf('here\n');
