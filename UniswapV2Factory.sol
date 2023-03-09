/**
 *Submitted for verification at Etherscan.io on 2020-05-04
 */

pragma solidity =0.5.16;

interface IUniswapV2Factory {
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    function feeTo() external view returns (address);

    function feeToSetter() external view returns (address);

    function getPair(
        address tokenA,
        address tokenB
    ) external view returns (address pair);

    function allPairs(uint) external view returns (address pair);

    function allPairsLength() external view returns (uint);

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair);

    function setFeeTo(address) external;

    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(
        address indexed sender,
        uint amount0,
        uint amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);

    function price0CumulativeLast() external view returns (uint);

    function price1CumulativeLast() external view returns (uint);

    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);

    function burn(address to) external returns (uint amount0, uint amount1);

    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2ERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint);

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint);

    function balanceOf(address owner) external view returns (uint);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);

    function transfer(address to, uint value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool);
}

interface IUniswapV2Callee {
    function uniswapV2Call(
        address sender,
        uint amount0,
        uint amount1,
        bytes calldata data
    ) external;
}

contract UniswapV2ERC20 is IUniswapV2ERC20 {
    using SafeMath for uint;

    string public constant name = "Uniswap V2";
    string public constant symbol = "UNI-V2";
    uint8 public constant decimals = 18;
    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    // 域分割
    bytes32 public DOMAIN_SEPARATOR;
    // keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");
    bytes32 public constant PERMIT_TYPEHASH =
        0x6e71edae12b1b97f4d1f60370fef10105fa2faae0126114a169c64845d6126c9;
    mapping(address => uint) public nonces;

    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    constructor() public {
        uint chainId;
        assembly {
            chainId := chainid
        }
        DOMAIN_SEPARATOR = keccak256(
            abi.encode(
                keccak256(
                    "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                ),
                keccak256(bytes(name)),
                keccak256(bytes("1")),
                chainId,
                address(this)
            )
        );
    }

    function _mint(address to, uint value) internal {
        totalSupply = totalSupply.add(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(address(0), to, value);
    }

    function _burn(address from, uint value) internal {
        balanceOf[from] = balanceOf[from].sub(value);
        totalSupply = totalSupply.sub(value);
        emit Transfer(from, address(0), value);
    }

    function _approve(address owner, address spender, uint value) private {
        allowance[owner][spender] = value;
        emit Approval(owner, spender, value);
    }

    function _transfer(address from, address to, uint value) private {
        balanceOf[from] = balanceOf[from].sub(value);
        balanceOf[to] = balanceOf[to].add(value);
        emit Transfer(from, to, value);
    }

    function approve(address spender, uint value) external returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }

    function transfer(address to, uint value) external returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint value
    ) external returns (bool) {
        if (allowance[from][msg.sender] != uint(-1)) {
            allowance[from][msg.sender] = allowance[from][msg.sender].sub(
                value
            );
        }
        _transfer(from, to, value);
        return true;
    }

    function permit(
        address owner,
        address spender,
        uint value,
        uint deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        require(deadline >= block.timestamp, "UniswapV2: EXPIRED");
        bytes32 digest = keccak256(
            abi.encodePacked(
                "\x19\x01",
                DOMAIN_SEPARATOR,
                keccak256(
                    abi.encode(
                        PERMIT_TYPEHASH,
                        owner,
                        spender,
                        value,
                        nonces[owner]++,
                        deadline
                    )
                )
            )
        );
        address recoveredAddress = ecrecover(digest, v, r, s);
        require(
            recoveredAddress != address(0) && recoveredAddress == owner,
            "UniswapV2: INVALID_SIGNATURE"
        );
        _approve(owner, spender, value);
    }
}

/**
 * @title 配对合约
 * UniswapV2ERC20实质上就是实现了ERC20标准，并且写死了lp token的name和symbol，即所有Pair合约的name和symbol都一样
 */
contract UniswapV2Pair is IUniswapV2Pair, UniswapV2ERC20 {
    using SafeMath for uint;
    // 使用uint224节省计算资源，并且选择了以太坊虚拟机(EVM)中IEEE754标准上的扩展实数格式来实现浮点数精度的支持，
    // 这样可以更好的支持交易手续费、价格等浮点数的运算。使用uint128则会降低对于浮点数精度的支持。
    using UQ112x112 for uint224;

    // 保证最小数量的流动性份额，是为了防止攻击，看白皮书3.4
    // 销毁第一次铸造的1e-15资金池份额，发送到全零地址而不是铸造者。
    // 10*10*10更节省gas
    uint public constant MINIMUM_LIQUIDITY = 10 ** 3;

    // ERC20 transfer函数选择器，为了使用call方法调用合约的transfer函数
    bytes4 private constant SELECTOR =
        bytes4(keccak256(bytes("transfer(address,uint256)")));

    address public factory;
    address public token0;
    address public token1;

    // 储备量0和储备量1，当前Pair合约持有的对应token数量
    // 这两个数值是用在价格预言机里使用的，在这里不使用，只在_update()函数中做更新
    uint112 private reserve0; // uses single storage slot, accessible via getReserves
    uint112 private reserve1; // uses single storage slot, accessible via getReserves

    // 更新储备量的时间戳
    // 主要是用于判断是不是区块的第一笔交易
    uint32 private blockTimestampLast; // uses single storage slot, accessible via getReserves

    // x*y=k的公式
    // 主要用于Uniswap V2所提供的价格预言机上，该数值会在每个区块的第一笔交易进行更新
    uint public price0CumulativeLast; // 价格0最后累计
    uint public price1CumulativeLast; // 价格1最后累计

    // 没开启收费时=0，开启收费=k
    uint public kLast; // 储备量0*储备量1，自最后一次流动性事件发生之后

    // 防止重入攻击的锁
    // openzepplin设置的1,2更节省gas
    uint private unlocked = 1;
    modifier lock() {
        require(unlocked == 1, "UniswapV2: LOCKED");
        unlocked = 0;
        _;
        unlocked = 1;
    }

    // 设置factory合约地址
    constructor() public {
        factory = msg.sender;
    }

    /**
     * @dev 获取储备量和上一个区块的时间戳，返回的是uint112的值了，不是256了
     * @return _reserve0 储备量0
     * @return _reserve1 储备量1
     * @return _blockTimestampLast 时间戳
     */
    function getReserves()
        public
        view
        returns (
            uint112 _reserve0,
            uint112 _reserve1,
            uint32 _blockTimestampLast
        )
    {
        _reserve0 = reserve0;
        _reserve1 = reserve1;
        _blockTimestampLast = blockTimestampLast;
    }

    // 使用call调用token合约的Transfer方法
    // 使用call是想直接获得函数的返回值，判断是否执行成功，因为一些erc20合约并没有按照erc20的标准返回一个成功标识符
    function _safeTransfer(address token, address to, uint value) private {
        (bool success, bytes memory data) = token.call(
            abi.encodeWithSelector(SELECTOR, to, value)
        );

        // success只是调用函数成功，还得判断调用函数执行也成功
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            "UniswapV2: TRANSFER_FAILED"
        );
    }

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(
        address indexed sender,
        uint amount0,
        uint amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );

    // 同步事件，在白皮书里也有解释含义
    event Sync(uint112 reserve0, uint112 reserve1);

    // 在工厂合约部署时调用一次
    // create2部署的合约地址可计算，并且后一次部署的合约可以把前一次部署的合约给覆盖掉，从而实现了合约的升级部署
    // Pair合约构造函数没有参数保证部署地址一致
    function initialize(address _token0, address _token1) external {
        require(msg.sender == factory, "UniswapV2: FORBIDDEN"); // sufficient check
        token0 = _token0;
        token1 = _token1;
    }

    // update reserves and, on the first call per block, price accumulators
    // 更新储备量
    function _update(
        uint balance0,
        uint balance1,
        uint112 _reserve0,
        uint112 _reserve1
    ) private {
        // 这里应该是获取uint112的最大值
        // 这种写法当前已经不支持，写为type(uint112).max
        require(
            balance0 <= uint112(-1) && balance1 <= uint112(-1),
            "UniswapV2: OVERFLOW"
        );

        // 时间戳转换，用这个算法把时间戳控制在32位范围之内
        uint32 blockTimestamp = uint32(block.timestamp % 2 ** 32);
        // 计算时间流逝
        uint32 timeElapsed = blockTimestamp - blockTimestampLast; // overflow is desired
        // 如果时间流逝大于0 && ...
        if (timeElapsed > 0 && _reserve0 != 0 && _reserve1 != 0) {
            // * never overflows, and + overflow is desired
            // 价格0最后累计 += 储备量1 * 2**112 / 储备量0 * 时间流逝
            price0CumulativeLast +=
                uint(UQ112x112.encode(_reserve1).uqdiv(_reserve0)) *
                timeElapsed;
            // 价格1最后累计 += 储备量0 * 2**112 / 储备量1 * 时间流逝
            price1CumulativeLast +=
                uint(UQ112x112.encode(_reserve0).uqdiv(_reserve1)) *
                timeElapsed;
        }

        // 更新储备量的三个字段
        reserve0 = uint112(balance0);
        reserve1 = uint112(balance1);
        blockTimestampLast = blockTimestamp;
        emit Sync(reserve0, reserve1);
    }

    // 如果收费开启，提取流动性相当于sqrt(k)增长的1/6
    // 看白皮书2.4 协议费用，uniswap包含0.05%的协议费用，开启feeTo就会把流动性赚取的1/6发送给feeTo，目前未开启
    // 白皮书内提供了计算方法，下边的就是这个公式
    // if fee is on, mint liquidity equivalent to 1/6th of the growth in sqrt(k)
    function _mintFee(
        uint112 _reserve0,
        uint112 _reserve1
    ) private returns (bool feeOn) {
        // 通过工厂合约获取feeTo的地址，不等于address(0)则是开启了铸造费
        address feeTo = IUniswapV2Factory(factory).feeTo();
        feeOn = feeTo != address(0);
        uint _kLast = kLast; // gas savings
        if (feeOn) {
            if (_kLast != 0) {
                // 计算_reserve0*_reserve1平方根
                uint rootK = Math.sqrt(uint(_reserve0).mul(_reserve1));
                // 计算K值的平方根
                uint rootKLast = Math.sqrt(_kLast);
                if (rootK > rootKLast) {
                    // 分子 = erc20总量 * (rootK - rootKLast)
                    uint numerator = totalSupply.mul(rootK.sub(rootKLast));
                    // 分母 = rootK * 5 + rootKLast
                    uint denominator = rootK.mul(5).add(rootKLast);
                    // 流动性 = 分子/分母
                    uint liquidity = numerator / denominator;
                    // 如果流动性>0，将流动性铸造给feeTo地址
                    if (liquidity > 0) _mint(feeTo, liquidity);
                }
            }
        } else if (_kLast != 0) {
            kLast = 0;
        }
    }

    /**
     * 当添加流动性（储备量）的时候铸造LP token给to地址，用于计算流动性收益
     * 添加流动性时需要做什么操作：
     * 1. 把token0，token1 transferto Pair
     * 2. Pair mint lp token to Provider
     */
    function mint(address to) external lock returns (uint liquidity) {
        /**
         * 获取添加的流动性的两个token的金额
         */
        // 当前函数发生在router合约向pair合约发送代币之后，流动性提供者的token0,1已经transferTo Pair
        // 此时Pair合约的balance已经增加了，但是reserve0,1还没增加
        // 因此通过此次的储备量方法查询和当前合约查询的token合约的数量是不一致的，其差值就是本次添加流动性的两种token的数量
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // 获取两个值，节省gas
        uint balance0 = IERC20(token0).balanceOf(address(this));
        uint balance1 = IERC20(token1).balanceOf(address(this));
        uint amount0 = balance0.sub(_reserve0);
        uint amount1 = balance1.sub(_reserve1);

        /**
         * 计算铸造费
         */
        bool feeOn = _mintFee(_reserve0, _reserve1);

        /**
         * 计算流动性，给to地址，并且销毁最小流动性金额的lp token
         */
        // 获取当前合约的lp token的总量，为0代表是首次提供流动性
        uint _totalSupply = totalSupply; // 为了节省gas，必须在此处定义，因为totalSupply可以在_mintFee中更新
        if (_totalSupply == 0) {
            // 流动性 = (amount0 * amount1)的平方根 - 1000, 1000会销毁，转给address(0)
            // 其实就是恒定乘积公式中的k值，这个公式确保了在任意时刻添加流动性时，Lptoken的价值和初始供应的tokenA和tokenB的比例无关
            liquidity = Math.sqrt(amount0.mul(amount1)).sub(MINIMUM_LIQUIDITY);
            _mint(address(0), MINIMUM_LIQUIDITY); // permanently lock the first MINIMUM_LIQUIDITY tokens
        } else {
            // 流动性 = 最小值(amount0 * _totalSupply / _reserve0, amount1 * _totalSupply / _reserve1)
            liquidity = Math.min(
                amount0.mul(_totalSupply) / _reserve0,
                amount1.mul(_totalSupply) / _reserve1
            );
        }
        // 把流动性mint给提供者
        require(liquidity > 0, "UniswapV2: INSUFFICIENT_LIQUIDITY_MINTED");
        _mint(to, liquidity);

        // 更新储备量
        _update(balance0, balance1, _reserve0, _reserve1);

        // 如果铸造费开关为on， 重新计算K值，K = reserve0*reserve1
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date

        emit Mint(msg.sender, amount0, amount1);
    }

    // this low-level function should be called from a contract which performs important safety checks
    /**
     * 撤出流动性时调用
     * lock修饰器是防止重入攻击
     * 返回token0,token1对应的可以取出的数值
     */
    function burn(
        address to
    ) external lock returns (uint amount0, uint amount1) {
        // 当状态变量被多次使用时最好赋值给一个临时变量，节省gas
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings

        // 获取当前合约token0,token1的余额
        uint balance0 = IERC20(_token0).balanceOf(address(this));
        uint balance1 = IERC20(_token1).balanceOf(address(this));

        // 获取当前合约要销毁的流动性余额
        // 合约怎么会有流动性余额呢？是流动性提供者通过路由合约发送到Pair合约要销毁的金额
        uint liquidity = balanceOf[address(this)];

        bool feeOn = _mintFee(_reserve0, _reserve1);

        // 计算撤出流动性时应该返还的token0,token1的数额
        uint _totalSupply = totalSupply; // gas savings, must be defined here since totalSupply can update in _mintFee
        // amount0 = 流动性总量*余额0/totalSupply, 使用余额确保按比例分配
        amount0 = liquidity.mul(balance0) / _totalSupply; // using balances ensures pro-rata distribution
        // amount1 = 流动性总量*余额1/totalSupply, 使用余额确保按比例分配
        amount1 = liquidity.mul(balance1) / _totalSupply; // using balances ensures pro-rata distribution
        require(
            amount0 > 0 && amount1 > 0,
            "UniswapV2: INSUFFICIENT_LIQUIDITY_BURNED"
        );

        // 销毁合约内的流动性，发送token0,token1给提供者，更新储备量
        _burn(address(this), liquidity);
        _safeTransfer(_token0, to, amount0);
        _safeTransfer(_token1, to, amount1);
        balance0 = IERC20(_token0).balanceOf(address(this));
        balance1 = IERC20(_token1).balanceOf(address(this));

        _update(balance0, balance1, _reserve0, _reserve1);

        // 如果铸造费开关为on， 重新计算K值，K = reserve0*reserve1
        if (feeOn) kLast = uint(reserve0).mul(reserve1); // reserve0 and reserve1 are up-to-date

        emit Burn(msg.sender, amount0, amount1, to);
    }

    // this low-level function should be called from a contract which performs important safety checks
    // 交换方法
    // 通过路由合约调用，其中收税的部分是在路由合约完成的
    // amount0Out, amount1Out都是扣除了税费之后的金额
    // 那直接调用这个方法不就不扣税了么？这个方法里校验了取出数额必须是满足扣税算法的数额
    function swap(
        uint amount0Out,
        uint amount1Out,
        address to,
        bytes calldata data
    ) external lock {
        // amount0Out, amount1Out有一个大于0即可
        require(
            amount0Out > 0 || amount1Out > 0,
            "UniswapV2: INSUFFICIENT_OUTPUT_AMOUNT"
        );

        // 确保输出数量0,1 < 储备数量0,1
        (uint112 _reserve0, uint112 _reserve1, ) = getReserves(); // gas savings
        require(
            amount0Out < _reserve0 && amount1Out < _reserve1,
            "UniswapV2: INSUFFICIENT_LIQUIDITY"
        );

        // 初始化变量
        uint balance0;
        uint balance1;
        {
            // 标记_token{0,1}的作用阈, 避免堆栈太深的错误
            address _token0 = token0;
            address _token1 = token1;
            require(to != _token0 && to != _token1, "UniswapV2: INVALID_TO");
            if (amount0Out > 0) _safeTransfer(_token0, to, amount0Out); // optimistically transfer tokens
            if (amount1Out > 0) _safeTransfer(_token1, to, amount1Out); // optimistically transfer tokens

            // 这里是闪电贷功能，后边再讲
            if (data.length > 0)
                IUniswapV2Callee(to).uniswapV2Call(
                    msg.sender,
                    amount0Out,
                    amount1Out,
                    data
                );

            balance0 = IERC20(_token0).balanceOf(address(this));
            balance1 = IERC20(_token1).balanceOf(address(this));
        }

        // 如果 余额0 > 储备量0 - amount0Out 则 amount0In = 余额0 - (储备量0 - amount0Out) 否则 amount0In = 0
        uint amount0In = balance0 > _reserve0 - amount0Out
            ? balance0 - (_reserve0 - amount0Out)
            : 0;
        // 如果 余额1 > 储备量1 - amount1Out 则 amount1In = 余额1 - (储备量1 - amount1Out) 否则 amount1In = 0
        uint amount1In = balance1 > _reserve1 - amount1Out
            ? balance1 - (_reserve1 - amount1Out)
            : 0;
        require(
            amount0In > 0 || amount1In > 0,
            "UniswapV2: INSUFFICIENT_INPUT_AMOUNT"
        );
        {
            // 标记 reserve{0,1}的作用阈, 避免堆栈太深的错误
            // 调整后的余额0 = 余额0 * 1000 - (amount0In * 3)
            uint balance0Adjusted = balance0.mul(1000).sub(amount0In.mul(3));
            // 调整后的余额1 = 余额1 * 1000 - (amount1In * 3)
            uint balance1Adjusted = balance1.mul(1000).sub(amount1In.mul(3));
            // 确认balance0Adjusted * balance1Adjusted >0 储备量0 * 储备量1 * 1000000
            // 作用：确保路由合约收税了
            require(
                balance0Adjusted.mul(balance1Adjusted) >=
                    uint(_reserve0).mul(_reserve1).mul(1000 ** 2),
                "UniswapV2: K"
            );
        }

        // 更新储备量
        _update(balance0, balance1, _reserve0, _reserve1);
        emit Swap(msg.sender, amount0In, amount1In, amount0Out, amount1Out, to);
    }

    // skim 方法是让余额强制等于储备量
    // 一般用于储备量溢出的情况，将多余的余额转出到to地址上，使余额重新等于储备量
    // 白皮书3.2.2中对skim和sync方法有说明
    function skim(address to) external lock {
        address _token0 = token0; // gas savings
        address _token1 = token1; // gas savings
        // 将 (合约余额token0,1-储备量0,1) 安全发送到to地址
        _safeTransfer(
            _token0,
            to,
            IERC20(_token0).balanceOf(address(this)).sub(reserve0)
        );
        _safeTransfer(
            _token1,
            to,
            IERC20(_token1).balanceOf(address(this)).sub(reserve1)
        );
    }

    // sync 方法是储备量强制等于余额，和skim方法相反
    function sync() external lock {
        _update(
            IERC20(token0).balanceOf(address(this)),
            IERC20(token1).balanceOf(address(this)),
            reserve0,
            reserve1
        );
    }
}

/**
 * @title 工厂合约
 * 作用：
 * 1. 创建Pair合约
 * 2. 设置收税地址
 * 3. 设置收税地址权限地址
 */
contract UniswapV2Factory is IUniswapV2Factory {
    // 状态变量设置为public类型，代替写对应的方法
    address public feeTo; // 收税的地址
    address public feeToSetter; // 可以设置收税地址的地址

    // 设置public类型的变量，代替写对应的方法
    mapping(address => mapping(address => address)) public getPair;
    address[] public allPairs; // 全部pair合约的地址

    // uint是存储的allPairs的长度，作用是知道被创建的pair合约的序号
    // 接口中已经定义了，重复定义这里
    event PairCreated(
        address indexed token0,
        address indexed token1,
        address pair,
        uint
    );

    // 构造函数需要设置收税地址的权限地址
    constructor(address _feeToSetter) public {
        feeToSetter = _feeToSetter;
    }

    function allPairsLength() external view returns (uint) {
        return allPairs.length;
    }

    function createPair(
        address tokenA,
        address tokenB
    ) external returns (address pair) {
        require(tokenA != tokenB, "UniswapV2: IDENTICAL_ADDRESSES");
        (address token0, address token1) = tokenA < tokenB
            ? (tokenA, tokenB)
            : (tokenB, tokenA);
        // 判断小的地址不等于0，那么大的更不等于0了，小技巧
        require(token0 != address(0), "UniswapV2: ZERO_ADDRESS");
        // 检查配对合约是否已经存在
        require(
            getPair[token0][token1] == address(0),
            "UniswapV2: PAIR_EXISTS"
        ); // single check is sufficient

        // 合约bytecode，不定长
        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(token0, token1));

        // 部署合约，并生成合约地址
        // create2生成合约地址，便于Router合约无需任何调用就可计算得到Pair合约地址
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        IUniswapV2Pair(pair).initialize(token0, token1); // 不在constructor里设置为了保持地址不变
        getPair[token0][token1] = pair;
        getPair[token1][token0] = pair; // populate mapping in the reverse direction
        allPairs.push(pair);
        emit PairCreated(token0, token1, pair, allPairs.length);
    }

    function setFeeTo(address _feeTo) external {
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
        feeTo = _feeTo;
    }

    function setFeeToSetter(address _feeToSetter) external {
        require(msg.sender == feeToSetter, "UniswapV2: FORBIDDEN");
        feeToSetter = _feeToSetter;
    }
}

// a library for performing overflow-safe math, courtesy of DappHub (https://github.com/dapphub/ds-math)

library SafeMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "ds-math-add-overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "ds-math-sub-underflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "ds-math-mul-overflow");
    }
}

// a library for performing various math operations

library Math {
    function min(uint x, uint y) internal pure returns (uint z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
    function sqrt(uint y) internal pure returns (uint z) {
        if (y > 3) {
            z = y;
            uint x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

// a library for handling binary fixed point numbers (https://en.wikipedia.org/wiki/Q_(number_format))

// range: [0, 2**112 - 1]
// resolution: 1 / 2**112

library UQ112x112 {
    uint224 constant Q112 = 2 ** 112;

    // encode a uint112 as a UQ112x112
    function encode(uint112 y) internal pure returns (uint224 z) {
        z = uint224(y) * Q112; // never overflows
    }

    // divide a UQ112x112 by a uint112, returning a UQ112x112
    function uqdiv(uint224 x, uint112 y) internal pure returns (uint224 z) {
        z = x / uint224(y);
    }
}
