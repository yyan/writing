#include "PopLayer.h"

using namespace std;

PopLayer::PopLayer(void):m__pMenu(NULL)
	, m_contentPadding(0)
	, m_contentPaddingTop(0)
	, m_callbackListener(NULL)
	, m_callback(NULL)
	, m__sfBackGround(NULL)
	, m__s9BackGround(NULL)
	, m__ltContentText(NULL)
	, m__ltTitle(NULL)
	, m__editBox(NULL)
{
}


PopLayer::~PopLayer(void)
{
	CC_SAFE_RELEASE(m__pMenu);
	CC_SAFE_RELEASE(m__sfBackGround);
	CC_SAFE_RELEASE(m__ltContentText);
	CC_SAFE_RELEASE(m__ltTitle);
	CC_SAFE_RELEASE(m__s9BackGround);
	CC_SAFE_RELEASE(m__editBox);
}

bool PopLayer::init(){
	bool bRef = false;
	do 
	{
		CC_BREAK_IF(!CCLayer::init());
		this->setContentSize(CCSizeZero);
		// 添加菜单
		CCMenu* menu = CCMenu::create();
		menu->setPosition(CCPointZero);
		setMenuButton(menu);

		setTouchEnabled(true);
		bRef = true;
	} while (0);
	return bRef;
}

void PopLayer::registerWithTouchDispatcher(){
	CCDirector::sharedDirector()->getTouchDispatcher()->addTargetedDelegate(this,-128,true);
}

bool PopLayer::ccTouchBegan(CCTouch *pTouch, CCEvent *pEvent){
	return true;
}

PopLayer* PopLayer::create(const char* backgroundImage){
	PopLayer* l = PopLayer::create();
	l->setSpriteBackGround(CCSprite::create(backgroundImage));
	l->setSprite9BackGround(CCScale9Sprite::create(backgroundImage));
	return l;
}

PopLayer* PopLayer::create(const string hanzi,const char* backgroundImage){
	PopLayer* l = PopLayer::create();
	l->setSpriteBackGround(CCSprite::create(backgroundImage));
	l->setSprite9BackGround(CCScale9Sprite::create(backgroundImage));
	l->setHanzi(hanzi);
	return l;
}

void PopLayer::setHanzi(string h){
	this->hanzi = h;
}
const char* PopLayer::getHanzi(){
	const char* re = "";
	if (getEditBoxHanzi())
	{
		 re = getEditBoxHanzi()->getText();
		 CCLog("EditBox : %s",getEditBoxHanzi()->getText());
	}
	return re;
}

void PopLayer::setTitle(const char* title, int fontsize){
	CCLabelTTF* ltfTitle = CCLabelTTF::create(title,"XingShu",fontsize);
	setLabelTitle(ltfTitle);
}

void PopLayer::setContentText(const char* text, int fontsize, int padding , int paddingTop){
	CCLabelTTF* ltf = CCLabelTTF::create(text, "XingShu", fontsize);
	setLabelContentText(ltf);
	m_contentPadding = padding;
	m_contentPaddingTop = paddingTop;
}

void PopLayer::setEditBox(){
	//添加输入框
	CCEditBox* editbox = CCEditBox::create(CCSizeMake(200,100),CCScale9Sprite::create("HelloWorld.png"));
	setEditBoxHanzi(editbox);
}

void PopLayer::setCallBackFunc(CCObject* targer, SEL_CallFuncN callfun){
	m_callbackListener = targer;
	m_callback = callfun;
}

bool PopLayer::addButton(const char* normalImage,const char* selectedImage ,const char* title, int tag){
	CCSize winSize = CCDirector::sharedDirector()->getWinSize();
	CCPoint pCenter = ccp(winSize.width/2,winSize.height/2);
	// 创建图片菜单按钮
	CCMenuItemImage* menuImage = CCMenuItemImage::create(normalImage, selectedImage, this, menu_selector(PopLayer::buttonCallback));
	menuImage->setTag(tag);
	menuImage->setPosition(pCenter);

	// 添加文字说明并设置位置
	CCSize imenu = menuImage->getContentSize();
	CCLabelTTF* ttf = CCLabelTTF::create(title, "XingShu", 20);
	ttf->setColor(ccc3(0, 0, 0));
	ttf->setPosition(ccp(imenu.width / 2, imenu.height / 2));
	//menuImage->addChild(ttf);

	getMenuButton()->addChild(menuImage);
	return true;
}

void PopLayer::buttonCallback(CCObject* pSender){
	CCNode* node = dynamic_cast<CCNode*>(pSender);
	CCLog("PopLayer::Touch tag %d",node->getTag());
	if (m_callback && m_callbackListener)
	{
		(m_callbackListener->*m_callback)(node);
	}
	this->removeFromParent();
}

void PopLayer::onEnter(){
	CCLayer::onEnter();

	CCSize winSize = CCDirector::sharedDirector()->getWinSize();
	CCPoint pCenter = ccp(winSize.width / 2, winSize.height / 2);

	CCSize contentSize;
	// 设定好参数，在运行时加载
	if (getContentSize().equals(CCSizeZero)) {
		getSpriteBackGround()->setPosition(ccp(winSize.width / 2, winSize.height / 2));
		this->addChild(getSpriteBackGround(), 0, 0);
		contentSize = getSpriteBackGround()->getTexture()->getContentSize();
	} else {
		CCScale9Sprite *background = getSprite9BackGround();
		background->setContentSize(getContentSize());
		background->setPosition(ccp(winSize.width / 2, winSize.height / 2));
		this->addChild(background, 0, 0);
		contentSize = getContentSize();
	}

	// 添加按钮，并设置其位置
	this->addChild(getMenuButton());
	float btnWidth = contentSize.width / (getMenuButton()->getChildrenCount() + 1);

	CCArray* array = getMenuButton()->getChildren();
	CCObject* pObj = NULL;
	int i = 0;
	CCARRAY_FOREACH(array, pObj){
		CCNode* node = dynamic_cast<CCNode*>(pObj);
		node->setPosition(ccp( winSize.width / 2 - contentSize.width / 2 + btnWidth * (i + 1), winSize.height / 2 - contentSize.height / 3));
		i++;
	}

	// 显示对话框标题
	if (getLabelTitle()){
		getLabelTitle()->setPosition(ccpAdd(pCenter, ccp(0, contentSize.height / 2 - 35.0f)));
		this->addChild(getLabelTitle());
	}

	// 显示文本内容
	if (getLabelContentText()){
		CCLabelTTF* ltf = getLabelContentText();
		ltf->setPosition(ccp(winSize.width / 2, winSize.height / 2));
		ltf->setDimensions(CCSizeMake(contentSize.width - m_contentPadding * 2, contentSize.height - m_contentPaddingTop));
		ltf->setHorizontalAlignment(kCCTextAlignmentLeft);
		this->addChild(ltf);
	}

	// 添加输入框
	if (getEditBoxHanzi())
	{
		CCEditBox* editbox = getEditBoxHanzi();
		editbox->setPosition(ccp(winSize.width/2,winSize.height/2));
		editbox->setTouchPriority(-128);	//设置触摸优先级，越小优先级越高
		editbox->setPlaceHolder(hanzi.c_str());
		editbox->setText(hanzi.c_str());
		editbox->setMaxLength(1);
		//设置键盘输入模式
		editbox->setInputMode(kEditBoxInputModeAny);
		//设置键盘缩回按钮为done
		editbox->setReturnType(kKeyboardReturnTypeDone);
		this->addChild(editbox);
	}

	// 弹出效果
	CCAction* popupLayer = CCSequence::create(CCScaleTo::create(0.0, 0.0),
		CCScaleTo::create(0.06, 1.05),
		CCScaleTo::create(0.08, 0.95),
		CCScaleTo::create(0.08, 1.0), NULL);
	this->runAction(popupLayer);
}

void PopLayer::onExit(){
	CCLayer::onExit();
	CCLog("popup on exit.");
}
